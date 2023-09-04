---
date: 2023-08-01T21:00:00+08:00
title: Nexus3
navWeight: 50 # Upper weight gets higher precedence, optional.
linkTitleIcon: <i class="fas fa-fw square"></i> # The icon of the link title, optional.
series:
  - Registry
categories:
  - Devops
---

### Deploy a Nexus3 in container on VM 

Load the image 
```bash
podman pull sonatype/nexus3:3.59.0
podman save sonatype/nexus3:3.59.0 -o nexus3.tar
podman load < nexus3.tar
``` 

Create a service inside `/etc/systemd/system/container-nexus3.service` with content below:  

```init
[Unit]
Description=Nexus Podman container
Wants=syslog.service

[Service]
User=nexus-system
Group=nexus-system
Restart=always
ExecStart=/usr/bin/podman run \
	--log-level=debug \
	--rm \
	-ti \
	--publish 8081:8081 \
	--name nexus \
	sonatype/nexus3:3.59.0

ExecStop=/usr/bin/podman stop -t 10 nexus

[Install]
WantedBy=multi-user.target
```
