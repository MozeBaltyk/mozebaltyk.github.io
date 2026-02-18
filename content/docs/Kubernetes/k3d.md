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
# Manual way
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# or with arkade:
arkade get k3d

# Auto-completion
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
# TODO 
loginctl enable-linger $(whoami)

# Either reload terminal or do below: 
export XDG_RUNTIME_DIR=/tmp/run-$(id -u)
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

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

echo -e "[Service]\nDelegate=cpu cpuset io memory pids" | \
sudo tee /etc/systemd/system/user@.service.d/delegate.conf > /dev/null

sudo systemctl daemon-reload
```

* The default *podman network* has dns disabled. To allow k3d cluster nodes to communicate with dns, so a new network must be created.

```bash
podman network create k3d
podman network inspect k3d -f '{{ .DNSEnabled }}'
```

* Create a local registry using the *podman network*

```bash
k3d registry create mycluster-registry --default-network k3d --port 5000 --delete-enabled
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


* For a Quick cluster use the registry and network created before:

```BASH
# args REQUIRED for rootless Podman — SERVER and AGENT
k3d cluster create mycluster \
  --registry-use k3d-mycluster-registry:5000 \
  --network k3d \
  --k3s-arg "--kubelet-arg=feature-gates=KubeletInUserNamespace=true@server:*" \
  --k3s-arg "--kubelet-arg=feature-gates=KubeletInUserNamespace=true@agent:*" \
  --k3s-arg "--kubelet-arg=fail-swap-on=false@server:*" \
  --k3s-arg "--kubelet-arg=fail-swap-on=false@agent:*"
```

## Admins

> [!IMPORTANT]
> Pay attention to always export those variables if you use *k3d* with *podman the rootless way*.
> Can be added to `~/.zshrc`
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

* Create a `registry.yaml`:

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

## Manage image in your local registry :

```BASH
# Not super usefull but ...
arkade get regctl
regctl completion zsh > "$ZSH/completions/_regctl"
regctl registry set --tls disabled localhost:5000
regctl repo ls localhost:5000

# check if REGISTRY_STORAGE_DELETE_ENABLED=true
podman inspect k3d-mycluster-registry --format '{{range .Config.Env}}{{println .}}{{end}}'

# List images and tags 
curl -s http://localhost:5000/v2/_catalog \
| jq -r '.repositories[]' \
| while read repo; do
    echo "Repository: $repo"
    curl -s http://localhost:5000/v2/$repo/tags/list | jq
  done 

# Delete an image and clean garbage collector
repo="backstage-backend"; tag="local"; \
digest=$(curl -sI \
  -H "Accept: application/vnd.oci.image.manifest.v1+json" \
  http://localhost:5000/v2/$repo/manifests/$tag \
  | awk -F': ' '/Docker-Content-Digest/ {print $2}' | tr -d '\r'); \
echo "Deleting $digest"; \
curl -v -X DELETE http://localhost:5000/v2/$repo/manifests/$digest
podman exec -it k3d-mycluster-registry registry garbage-collect /etc/docker/registry/config.yml
# then restart registry to make it effective
podman stop k3d-mycluster-registry && podman start k3d-mycluster-registry
```

## Cleanup

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
