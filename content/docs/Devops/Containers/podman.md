---
date: 2023-08-01T21:00:00+08:00
title: 🐬 Podman
navWeight: 90 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - Devops
tags:
  - Containers
---

## Description

* Buildah: is used to build Open Container Initiative (OCI) format or Docker format container images without the need for a daemon.

* Podman: provides the ability to directly run container images without a daemon. Podman can pull container images from a container registry, if they are not available locally.

* Skopeo: offers features for pulling and pushing containers to registries. Moving containers between registries is supported. Container image inspection is also offered and some introspective capabilities can be performed, without first downloading the container itself.


## Podman

### for WSL 

* Warning due to the Filesystem

```Powershell
wsl --set-version Ub22 2
```

```bash 
sudo mount --make-rshared /
```

### Podman Usage

* Login and handle connexion to registry

```bash
# Set CA cert for Podman 
sudo mkdir /etc/containers/certs.d/my-registry.example.com/
openssl s_client -showcerts -connect my-registry.example.com:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > /etc/containers/certs.d/my-registry.example.com/ca.crt

# Login 
podman login --get-login
podman login -u init -p xxxxxxxxxxxxxx  quay.example.com:8443
podman login -u registry-admin -p <PWD> registry.k3s.example.com

# Check podman context
podman info
```

* View

```bash
# List containers
podman ps -a 

# List images 
podman images 
```

* Cleanup 

```bash
# Kill containers 
podman kill $(podman ps -q)

# remove containers
podman rm $(podman ps -qa)

# remove all images
podman rmi $(podman images -qa) -f

# Remove everything
podman system reset
```

* Export/Import images 

```bash
# Export and Load an image 
podman pull docker.io/gitea/gitea:1-rootless
podman save docker.io/gitea/gitea:1-rootless -o gitea-rootless.tar
podman load < gitea-rootless.tar

# Import in registry
podman load < kibana.tar
podman tag docker.elastic.co/kibana/kibana:8.5.3 quay.example.com:8443/kibana/kibana:8.5.3
podman push quay.example.com:8443/kibana/kibana:8.5.3
podman pull quay.example.com:8443/kibana/kibana:8.5.3
```

* Run a container
```bash
podman run --rm -it registry.access.redhat.com/rhel7 /bin/bash             # run image and kill once you exit (just for test purpose) 
podman run --rm -it rhel7 /usr/sbin/ip a                                   # the ip command does not exist in the conteneur 
podman run -v /usr/sbin:/usr/sbin --rm -it rhel7 /usr/sbin/ip a            # so map /usr/sbin inside destination /usr/sbin then you get the ip command

# Web app in workdir /opt
podman run -d -p 8080:8000 --name="python_web" \
       -w /opt \
       -v /opt/rhel_data:/var/www/html ubi8/python-39 \
       -- python -m http.server -d /var/www/html
```

* Inspect from a container

```bash
# Get the IP
sudo podman inspect --format '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' gitea-db

# State / Started At
podman inspect -f {{.State.StartedAt}} python_web
```

* Handle and check logs 

```bash
# Follow logs since 10 min 
podman logs -f --since 10m <ContainerID>

# mount log 
podman run -v /dev/log:/dev/log --rm ubi8 logger Testing logging to the host
journalctl | grep "Testing logging"
```

## Skopeo

```bash
skopeo inspect docker://registry.access.redhat.com/ubi8
```

## Buildah



## Sources 

[Tutorial](http://redhatgov.io/workshops/containers_101/exercise1.2/)