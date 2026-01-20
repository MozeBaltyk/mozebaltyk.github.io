--- 
title: 💫 Podman as a service
description: "Do we really need Kubernetes when you will see what is below..."
date: 2026-01-15T03:48:10+02:00
draft: false
noindex: false
featured: true
comment: true
toc: true
reward: true
pinned: false
carousel: true
series:
  - Posts
categories:
  - Devops
tags:
  - Containers
  - Devops
  - Podman
  - Repository
authors:
  - mozebaltyk
images: 
  - ./carousel/podman-systemd.jpg
sidebar: false
---

## Introduction

It's nice to run everything on k8s, but as Yaakov was underling it in [his blog](https://blog.yaakov.online/replacing-kubernetes-with-systemd/)

> My personal experience on Azure Kubernetes Service was that I immediately lost a massive chunk of RAM to their Kubernetes implementation, and it used about 7–10% idle CPU on worker nodes.  
> Even with a single-instance MicroK8s on a small VPS, I observed an idle CPU load hovering around 12% on a 2× vCPU x86_64 box.  
> K3s, which is supposed to be leaner, still shows about 6% constant CPU consumption on a 2× vCPU Ampere A1 machine.  
> <small>— [Yaakov Blog](https://blog.yaakov.online/replacing-kubernetes-with-systemd/), Feb 04, 2024</small>

Podman brings several important advantages:  

* It can run **rootless**, which improves security.
* It integrates well with **systemd**, making containers easy to manage as standard services.
* It offers useful features such as **auto-update** with  
  `--label "io.containers.autoupdate=registry"`.


Instead of running containers manually, we let `systemd`:

- Start containers at boot
- Restart them on failure
- Stop them cleanly
- Track logs and status
- Seamless integration with monitoring tools

## The basic example

Here, we run a container then init the systemd config file from it:

* Let’s start a container normally:
```bash
podman run -d \
  --name my-nginx \
  -p 8080:80 \
  nginx:latest
```

* Podman can generate a systemd unit automatically:
```bash
podman generate systemd my-nginx
```

Here is more or less what you should get:
```ini
[Unit]
Description=Podman container-my-nginx.service
After=network.target

[Service]
Restart=on-failure
ExecStart=/usr/bin/podman start my-nginx
ExecStop=/usr/bin/podman stop -t 10 my-nginx
ExecStopPost=/usr/bin/podman rm -f my-nginx

[Install]
WantedBy=multi-user.target
```

* Check it:

```bash
systemctl --user status container-my-nginx
systemctl --user restart container-my-nginx
journalctl --user -u container-my-nginx
```

## One interesting example... Gitea

A few important notes:

{{< bs/alert info >}}
{{< markdownify >}}
If you run `podman` as a user, use the **rootless** container image.  
In this example: `docker.io/gitea/gitea:1-rootless`   
{{< /markdownify >}}
{{< /bs/alert >}}

{{< bs/alert info >}}
{{< markdownify >}}
We let *systemd* download and run the container for us.
{{< /markdownify >}}
{{< /bs/alert >}}

{{< bs/alert warning >}}
{{< markdownify >}}
Do **NOT** use `Type=forking` with `podman run`, as Podman does not fork in the way *systemd* expects.  
{{< /markdownify >}}
{{< /bs/alert >}}

* The dependency chain is as follows: 

```css
network-online.target
  |→ podman-network-gitea-net.service
      |→ container-gitea-db.service
            |→ container-gitea-app.service
```

### Create network systemd unit

{{< code-snippet podman-network-gitea-net.service ini>}}

This is the manual equivalent approach, but be careful:  
if you create the network manually, the `podman-network-gitea-net.service` may fail due to a conflict.  
This service is a dependency for the following units.

```bash
# Create network manually
podman network create gitea-net

# Check
podman network ls
NETWORK ID    NAME        DRIVER
546e4f544220  gitea-net   bridge
2f259bab93aa  podman      bridge

# in case, you need to reset
sudo systemctl stop podman-network-gitea-net.service
sudo systemctl disable podman-network-gitea-net.service
sudo systemctl reset-failed podman-network-gitea-net.service
sudo systemctl daemon-reload
sudo systemctl enable podman-network-gitea-net.service
sudo systemctl start podman-network-gitea-net.service
sudo systemctl status podman-network-gitea-net.service
```

### Create the MariaDB service

{{< code-snippet container-gitea-db.service ini >}}

### Create gitea systemd unit

{{< code-snippet container-gitea-app.service ini >}}

The data and configuration are stored in `/var/lib/containers/storage/volumes/`  
as persistent volumes: `gitea-config-volume` and `gitea-data-volume`.

### Run the containers

Services run as root:

```bash
# Re-read and enable systemd service 
sudo systemctl daemon-reload
sudo systemctl enable podman-network-gitea-net.service
sudo systemctl enable container-gitea-db.service

# Enable and start Gitea service
sudo systemctl enable --now container-gitea-app

# Checks
sudo podman ps
systemctl status container-gitea-app.service
journalctl -u container-gitea-app.service -b
journalctl -u container-gitea-app.service -o cat
``` 

**Important:** services running in a user session are created in  
`$HOME/.config/containers/systemd/`.

and executed with: 

```bash
# Re-read and enable systemd service 
systemctl --user daemon-reload
systemctl --user enable podman-network-gitea-net.service
systemctl --user enable container-gitea-db.service

# Enable and start Gitea service
systemctl --user enable --now container-gitea-app

# Checkings
podman ps
systemctl status container-gitea-app.service
journalctl -u container-gitea-app.service -b

systemctl list-unit-files | grep gitea
container-gitea-app.service                                                   enabled         enabled
container-gitea-db.service                                                    enabled         enabled
podman-network-gitea-net.service                                              enabled         enabled
```

## Why not *Docker Compose* or *Kubernetes*?

Why not *docker-compose*, which does roughly the same thing?

Because services come with important advantages. *docker-compose* is not a service: it does not start at boot, it is not monitored by the operating system, and it does not integrate directly with *systemd*. It is excellent for development and testing, but less suitable for production.

Why not *Kubernetes manifests*, which do the same thing — and more?

Because even the most basic single-node k3s setup consumes resources. In cloud environments, everything is billable, and Kubernetes also introduces additional complexity that may be unnecessary for small or simple deployments.

In conclusion, running containers as first-class *systemd* services with Podman offers a pragmatic alternative to Kubernetes for many single-node or small-scale deployments. You get predictable startup behavior, proper dependency management, clean shutdowns, logging, and monitoring — all without the overhead and complexity of a full orchestration platform.

## What’s next?

At this point in the post, I want to look a bit ahead and suggest some directions that could be explored without going into too much detail.

### Quadlet 

Quadlet was originally developed to simplify the process. You can think of it as a *Docker Compose* or a *Kubernetes manifest* for **systemd**. The project has since been archived because it is now directly integrated into Podman itself.

I won’t go into more detail on this topic here, as I haven’t used it yet to form a solid opinion. I mainly want to underline its existence.

### A service with *docker-compose* 

To get the best of both worlds, *docker-compose* can be launched from *systemd*. In this case, the app, database, and network are no longer split into multiple services but merged into a single one.

### Cloud-init for further automation

*systemd* can be easily configured during first boot with *cloud-init*. A common automation scenario on cloud providers could be:

**OpenTofu → Cloud-init → systemd → Podman containers**

## Sources

* [Yaakov Blog](https://blog.yaakov.online/replacing-kubernetes-with-systemd/) 
* [The Gitea example](https://blog.while-true-do.io/podman-setup-gitea/)
* [Redhat](https://www.redhat.com/en/blog/quadlet-podman)
* [Gitea config](https://docs.gitea.com/next/administration/config-cheat-sheet)