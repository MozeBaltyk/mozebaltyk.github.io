---
date: 2026-02-03T21:00:00+08:00
title: 🐎 K3D
navWeight: 60 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - Devops
tags:
  - Kubernetes
  - Infrastructure
---

*K3D* equal k3s in a container. a tools to create *single-* and *multi-node* k3s clusters.
Our favorite use case, is with `podman` and *rootless*. So there is some customization upstream to do. 

One downside I’ve found with *k3d* is that the Kubernetes version it uses is behind the current *k3s* release. 

## Install 

```bash
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

k3d completion zsh > "$ZSH/completions/_k3d"
```

## Tweaks for podman and rootless 

* The issue:

```bash
k3d cluster create test

ERRO[0000] Failed to get nodes for cluster 'test': docker failed to get containers with labels 'map[k3d.cluster:test]': failed to list containers: permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.46/containers/json?all=1&filters=%7B%22label%22%3A%7B%22app%3Dk3d%22%3Atrue%2C%22k3d.cluster%3Dtest%22%3Atrue%7D%7D": dial unix /var/run/docker.sock: connect: permission denied
```

* The solution:

```bash
sudo mkdir -p /etc/containers/containers.conf.d
sudo sh -c "echo 'service_timeout=0' > /etc/containers/containers.conf.d/timeout.conf"

sudo ln -s /run/podman/podman.sock /var/run/docker.sock

XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
export DOCKER_SOCK=$XDG_RUNTIME_DIR/podman/podman.sock

systemctl --user enable --now podman.socket
```

* If `/sys/fs/cgroup/cgroup.controllers` is present on your system, you are using v2, otherwise you are using v1.

* in **rootless**, to run properly we need to enable CPU, CPUSET, and I/O delegation

```bash
sudo mkdir -p /etc/systemd/system/user@.service.d
cat > /etc/systemd/system/user@.service.d/delegate.conf <<EOF
[Service]
Delegate=cpu cpuset io memory pids
EOF
systemctl daemon-reload
```

* The default *podman network* has dns disabled. To allow k3d cluster nodes to communicate with dns, so a new network must be created.

```bash
podman network create k3d
podman network inspect k3d -f '{{ .DNSEnabled }}'
true
```

* Create a local registry using the *podman network*
```bash
k3d registry create --default-network podman mycluster-registry

k3d cluster create --registry-use mycluster-registry mycluster
```

## Admins

> [!IMPORTANT]
> Pay attention to always export those variables if you use *k3d* with *podman* and *rootless*
>       
> `XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}`      
> `export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock`   
> `export DOCKER_SOCK=$XDG_RUNTIME_DIR/podman/podman.sock`    
>        

```bash
k3d cluster list
k3d node list
k3d registry list
```

* Create a `config.yaml`

```yaml
apiVersion: k3d.io/v1alpha5
kind: Simple
image: rancher/k3s:v1.29.3+k3s1

metadata:
  name: mycluster

servers: 1
agents: 1

options:
  k3s:
    extraArgs:
      - arg: "--disable=traefik"
        nodeFilters:
          - server:*
      - arg: "--disable=servicelb"
        nodeFilters:
          - server:*

registries:
  use:
    - mycluster-registry
```

```bash
k3d cluster create --config config.yaml
```


## Sources 

[About local registry](https://thoughtexpo.com/k3d-images/)