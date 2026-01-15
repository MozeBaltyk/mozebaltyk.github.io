--- 
title: 💫 Podman as a service
description: "Do we really need kubernetes when you will see what is below..."
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

<!--more-->
Do we really need kubernetes when you will see what is below...

It's nice to run everything on k8s but as Yaakov was underling it in [his blog](https://blog.yaakov.online/replacing-kubernetes-with-systemd/)

> My personal experience on Azure Kubernetes Service was that I immediately lose a massive chunk of RAM to their Kubernetes implementation, and it uses about 7-10% idle CPU on worker nodes. 
> Even with single-instance Microk8s on a small VPS I had an idle CPU load hovering around 12% on a 2x vCPU x86_64 box, and K3S which is supposed to be leaner is at about 6% constant CPU consumption on a 2x vCPU Ampere A1 machine.    
> [Yaakov Blog](https://blog.yaakov.online/replacing-kubernetes-with-systemd/) Feb 04, 2024

Podman bring the big advantage to be rootless which allow it to be transform as systemd service. 
Doing so, we are able to launch it as a normal service. 

Instead of running containers manually, we let `systemd`:
- Start containers at boot
- Restart them on failure
- Stop them cleanly
- Track logs and status

Podman come with some nice feature like:
- Auto-update with `--label "io.containers.autoupdate=registry"`

## How to do it ?

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

Here more a less what you should get...
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

### Interesting example... Gitea

{{< bs/alert info >}}
{{< markdownify >}}
If you run `podman` with your user, take the `rootless` container.     
In this example `docker.io/gitea/gitea:1-rootless`   
{{< /markdownify >}}
{{< /bs/alert >}}

Here, we launch directly systemd which will download and run the container for us:

```bash
# Create gitea systemd unit
$ sudo vi /etc/systemd/system/container-gitea-app.service
```

```ini
# container-gitea-app.service
[Unit]
Description=Podman container-gitea-app.service

Wants=network.target
After=network-online.target
RequiresMountsFor=/var/lib/containers/storage /var/run/containers/storage

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=on-failure
TimeoutStopSec=70
PIDFile=%t/container-gitea-app.pid
Type=forking

ExecStartPre=/bin/rm -f %t/container-gitea-app.pid %t/container-gitea-app.ctr-id
ExecStart=/usr/bin/podman container run \
          --conmon-pidfile %t/container-gitea-app.pid \
          --cidfile %t/container-gitea-app.ctr-id \
          --cgroups=no-conmon \
          --replace \
          --detach \
          --tty \
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
          --label "io.containers.autoupdate=registry" \
          --name gitea-app \
          docker.io/gitea/gitea:1-rootless

ExecStop=/usr/bin/podman container stop \
          --ignore \
          --cidfile %t/container-gitea-app.ctr-id \
          -t 10

ExecStopPost=/usr/bin/podman container rm \
          --ignore \
          -f \
          --cidfile %t/container-gitea-app.ctr-id

[Install]
WantedBy=multi-user.target default.target
```

The data and config will be store in `/var/lib/containers/storage/volumes/` as persisted volumes `gitea-config-volume` and `gitea-data-volume`.

* Run the container:

```bash
# Re-read systemd service file
$ sudo systemctl daemon-reload

# Enable and start the service
$ sudo systemctl enable --now container-gitea-app

# Check the service
$ sudo systemctl status container-gitea-app

# Check the container
$ sudo podman ps
```

## Sources

* [Yaakov Blog](https://blog.yaakov.online/replacing-kubernetes-with-systemd/) 
* [The Gitea example](https://blog.while-true-do.io/podman-setup-gitea/)