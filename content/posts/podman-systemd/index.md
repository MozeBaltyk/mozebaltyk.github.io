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
  - Devops
categories:
  - Posts
tags:
  - Containers
  - Devops
  - Podman
  - Repository
authors:
  - mozebaltyk
images: [./podman-systemd/carousel.jpg]
sidebar: false
---

## Introduction

It's nice to run everything on k8s, but as Yaakov was underling it in [his blog](https://blog.yaakov.online/replacing-kubernetes-with-systemd/)

> My personal experience on Azure Kubernetes Service was that I immediately lost a massive chunk of RAM to their Kubernetes implementation, and it used about 7–10% idle CPU on worker nodes.  
> Even with a single-instance MicroK8s on a small VPS, I observed an idle CPU load hovering around 12% on a 2× vCPU x86_64 box.  
> K3s, which is supposed to be leaner, still shows about 6% constant CPU consumption on a 2× vCPU Ampere A1 machine.  
> — [Yaakov Blog](https://blog.yaakov.online/replacing-kubernetes-with-systemd/), Feb 04, 2024

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

## How to do it

### Basic example

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

### One interesting example... Gitea

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

network-online.target -> podman-network-gitea-net.service -> container-gitea-db.service -> container-gitea-app.service    

#### Create network systemd unit

```ini
# /etc/systemd/system/podman-network-gitea-net.service
[Unit]
Description=Podman network gitea-net
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes

# Create network
ExecStart=/usr/bin/podman network create gitea-net

# Optional: remove network on stop (only if you really want ownership)
ExecStop=/usr/bin/podman network rm gitea-net

[Install]
WantedBy=multi-user.target
```

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

#### Create the MariaDB service

```ini
# /etc/systemd/system/container-gitea-db.service
[Unit]
Description=Gitea Database (MariaDB, Podman)
Wants=network-online.target
After=network-online.target
RequiresMountsFor=/var/lib/containers/storage

# If you manage the network via systemd
Requires=podman-network-gitea-net.service
After=podman-network-gitea-net.service

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=on-failure
RestartSec=5
TimeoutStartSec=120
TimeoutStopSec=70

Type=notify
NotifyAccess=all

# Ensure network exists (safe if already created or not)
ExecStartPre=/bin/sh -c '/usr/bin/podman network exists gitea-net || /usr/bin/podman network create gitea-net'

ExecStart=/usr/bin/podman run \
  --name gitea-db \
  --replace \
  --detach \
  --sdnotify=conmon \
  --network gitea-net \
  --env MYSQL_ROOT_PASSWORD=strong-root-password \
  --env MYSQL_DATABASE=gitea \
  --env MYSQL_USER=gitea \
  --env MYSQL_PASSWORD=password \
  --volume gitea-db-volume:/var/lib/mysql:Z \
  --health-cmd='mysqladmin ping -h 127.0.0.1 --silent' \
  --health-interval=5s \
  --health-retries=10 \
  docker.io/library/mariadb:11

ExecStop=/usr/bin/podman stop \
  --ignore \
  --time 10 \
  gitea-db

ExecStopPost=/usr/bin/podman rm \
  --ignore \
  gitea-db

[Install]
WantedBy=multi-user.target
```

#### Create gitea systemd unit

```ini
# /etc/systemd/system/container-gitea-app.service
[Unit]
Description=Gitea (Podman container)
Wants=network-online.target
After=network-online.target
RequiresMountsFor=/var/lib/containers/storage

# If you manage the db via systemd
Requires=container-gitea-db.service
After=container-gitea-db.service

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=on-failure
RestartSec=5
TimeoutStartSec=120
TimeoutStopSec=70

Type=notify
NotifyAccess=all

# Ensure db exists and healthy
ExecStartPre=/bin/sh -c 'until podman inspect --format "{{.State.Health.Status}}" gitea-db | grep -q healthy; do sleep 2; done'

ExecStart=/usr/bin/podman run \
  --name gitea-app \
  --replace \
  --detach \
  --sdnotify=conmon \
  --env DB_TYPE=mysql \
  --env DB_HOST=gitea-db:3306 \
  --env DB_NAME=gitea \
  --env DB_USER=gitea \
  --env DB_PASSWD=password \
  --volume gitea-data-volume:/var/lib/gitea:Z \
  --volume gitea-config-volume:/etc/gitea:Z \
  --network gitea-net \
  --publish 2222:2222 \
  --publish 3000:3000 \
  --label io.containers.autoupdate=registry \
  docker.io/gitea/gitea:1-rootless

ExecStop=/usr/bin/podman stop \
  --ignore \
  --time 10 \
  gitea-app

ExecStopPost=/usr/bin/podman rm \
  --ignore \
  gitea-app

[Install]
WantedBy=multi-user.target
```

The data and configuration are stored in `/var/lib/containers/storage/volumes/`  
as persistent volumes: `gitea-config-volume` and `gitea-data-volume`.

#### Run the containers

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

## Quadlet 

Quadlet was originally developed to simplify the process. You can think of it as a *Docker Compose* or a *Kubernetes manifest* for **systemd**. The project has since been archived because it is now directly integrated into Podman itself.

I won’t go into more detail on this topic here, as I haven’t used it enough yet to form a solid opinion.   

## Why not *Docker Compose* or *Kubernetes*?

Why not *docker-compose*, which does pretty much the same thing?
Because, as mentioned at the beginning of this article, services bring advantages. *docker-compose* is not a service. It does not start at boot, it is not monitored by the operating system, and it does not integrate with *systemd*. It is excellent for development and testing, but less suitable for production.

Why not *Kubernetes manifests*, which do the same thing and even more?
Because, as mentioned earlier, even the most basic single-node k3s setup consumes resources. In cloud environments, everything is billable, and Kubernetes also introduces additional complexity that may be unnecessary for small or simple deployments.

In conclusion, running containers as first-class *systemd* services with Podman offers a pragmatic alternative to Kubernetes for many single-node or small-scale deployments. You get predictable startup behavior, proper dependency management, clean shutdowns, logging, and monitoring — all without the overhead and complexity of a full orchestration platform.

## Sources

* [Yaakov Blog](https://blog.yaakov.online/replacing-kubernetes-with-systemd/) 
* [The Gitea example](https://blog.while-true-do.io/podman-setup-gitea/)
* [Redhat](https://www.redhat.com/en/blog/quadlet-podman)
* [Gitea config](https://docs.gitea.com/next/administration/config-cheat-sheet)