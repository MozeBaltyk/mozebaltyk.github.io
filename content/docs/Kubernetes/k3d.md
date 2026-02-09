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

**Note** for ARM PC: 
```BASH
sudo apt install qemu-user-static
podman run --rm --privileged multiarch/qemu-user-static --reset -p yes
``` 

## Install 

```bash
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

k3d completion zsh > "$ZSH/completions/_k3d"
```

or with arkade:

```bash
arkade get k3d
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
```

* Create a local registry using the *podman network*

```bash
k3d registry create mycluster-registry --default-network k3d --port 5000

# Output
# You can now use the registry like this (example):
# 1. create a new cluster that uses this registry
k3d cluster create --registry-use k3d-mycluster-registry:5000

# 2. tag an existing local image to be pushed to the registry
docker tag nginx:latest k3d-mycluster-registry:5000/mynginx:v0.1

# 3. push that image to the registry
docker push k3d-mycluster-registry:5000/mynginx:v0.1

# 4. run a pod that uses this image
kubectl run mynginx --image k3d-mycluster-registry:5000/mynginx:v0.1
```

* *podman* does not appreciate http... but let do an execption: `sudo vi ~/.config/containers/registries.conf`.   
  Add and restart with `systemctl --user restart podman`

```toml
[[registry]]
location = "localhost:5000"
insecure = true
```

* Push some image and Check registry at :
- **http://localhost:5000/v2/_catalog**  
- **http://k3d-mycluster-registry.localhost:5000/v2/_catalog** 

* For a Quick cluster:

```BASH
k3d cluster create --registry-use k3d-mycluster-registry:5000 mycluster
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
podman ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}"
```

* Create a `config.yaml`

```yaml
apiVersion: k3d.io/v1alpha5
kind: Simple
metadata:
  name: MyCluster

network: k3d

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
      # REQUIRED for rootless Podman — SERVER and AGENT
      - arg: "--kubelet-arg=feature-gates=KubeletInUserNamespace=true"
        nodeFilters:
          - server:*
          - agent:*
      - arg: "--kubelet-arg=fail-swap-on=false"
        nodeFilters:
          - server:*
          - agent:*
  k3d:
    wait: true
    timeout: "60s"
    disableLoadbalancer: true

registries:
  use:
    - k3d-mycluster-registry:5000
```

* create a `registry.yaml`:

```yaml
mirrors:
  "localhost:5000":
    endpoint:
      - http://k3d-mycluster-registry:5000
```

* Launch it

```bash
k3d cluster create --config config.yaml --registry-config registry.yaml
```

* Restart k3d : 

```BASH
# Restart registry
podman start k3d-mycluster-registry
podman ps -f name=k3d-mycluster-registry

# Restart K3d
k3d cluster start mycluster
```

* Cleanup

```bash
k3d cluster delete --config config.yaml
k3d registry delete k3d-mycluster-registry

# Should be clean
podman ps -a
podman network ls
podman volume ls
```


## Sources 

[Official doc for podman](https://k3d.io/v5.8.3/usage/advanced/podman/#podman-network)

[Official doc for config](https://k3d.io/v5.8.3/usage/configfile/#all-options-example)

[About local registry](https://thoughtexpo.com/k3d-images/)
