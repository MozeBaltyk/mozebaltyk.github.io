--- 
title: 💫 Podman as a service
description: "Do we really need kubernetes when you will see what is below..."
date: 2025-07-03T03:48:10+02:00
noindex: false
featured: true
draft: true
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
authors:
  - mozebaltyk
images: [./podman-systemd/carousel.webp]
sidebar: false
---

<!--more-->
Do we really need kubernetes when you will see what is below...

Podman have the big advantage to be rootless which allow it to be transform as systemd service. Doing so, we are able to launch it as a normal service. 

Instead of running containers manually, we let `systemd`:
- Start containers at boot
- Restart them on failure
- Stop them cleanly
- Track logs and status

## How to do it ?

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

## Some other interesting example ...

Thanks to [Yaakov](https://blog.yaakov.online/replacing-kubernetes-with-systemd/)