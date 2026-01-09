---
date: 2023-08-01T21:00:00+08:00
title: Gitea
navWeight: 50 # Upper weight gets higher precedence, optional.
nav_icon:
  vendor: bootstrap
  name: cup-hot
  color: grey
series:
  - Devops
categories:
  - Docs
tags:
  - Git
  - Repository
---


## Prerequis

	- Firewalld activated, important otherwise the routing to the app is not working 
	- Podman, jq installed


## Import image

```bash
podman pull docker.io/gitea/gitea:1-rootless
podman save docker.io/gitea/gitea:1-rootless -o gitea-rootless.tar
podman load < gitea-rootless.tar
```

## Install

cat /etc/systemd/system/container-gitea-app.service

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
          --env DB_TYPE=sqlite3 \
          --env DB_HOST=gitea-db:3306 \
          --env DB_NAME=gitea \
          --env DB_USER=gitea \
          --env DB_PASSWD=9Oq6P9Tsm6j8J7c18Jxc \
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

Configuration inside `/var/lib/containers/storage/volumes/gitea-config-volume/_data/app.ini`

```ini
[server]
APP_DATA_PATH           = /var/lib/gitea
SSH_DOMAIN              = localhost
HTTP_PORT               = 3000
ROOT_URL                = http://gitea.example.local:3000/
DISABLE_SSH             = false
; In rootless gitea container only internal ssh server is supported
START_SSH_SERVER        = true
SSH_PORT                = 2222
SSH_LISTEN_PORT         = 2222
BUILTIN_SSH_SERVER_USER = git
LFS_START_SERVER        = true
DOMAIN                  = example.local
LFS_JWT_SECRET          = Cn_qAC8UnzbApyzsBvAGHnecCkImxpcUeRZInT0vlxU
OFFLINE_MODE            = false
```

```bash
# Start app
systemctl daemon-reload 
systemctl start container-gitea-app

# Get IP 
sudo podman inspect --format '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' gitea-app
sudo podman inspect --format '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' gitea-db

# Get inside the container
podman exec -it gitea-app /bin/bash

# inside the container
bash-5.1$ gitea admin user list
bash-5.1$ gitea admin user create --username local_admin --email admins@email.earth --admin --random-password
generated random password is 'qwertyuiop'
New user 'local_admin' has been successfully created!
```

## Sources:

https://www.digitalocean.com/community/tutorials/how-to-install-gitea-on-ubuntu-using-docker

https://blog.while-true-do.io/podman-setup-gitea/