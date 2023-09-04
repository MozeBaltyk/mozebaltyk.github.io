---
date: 2023-08-01T21:00:00+08:00
title: Podman
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Containers
categories:
  - Devops
---


```bash
# remove containers
podman rm $(podman ps -a -q)
# remove all images
podman rmi $(podman images -qa) -f
```
