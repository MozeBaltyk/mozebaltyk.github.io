---
date: 2023-08-01T21:00:00+08:00
title: 🏭 Docker
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - Devops
tags:
  - Registry
  - Containers
---

See also documentation about Podman and Docker

## How to use a docker regsitry   

```bash 
# list index catalog
curl https://registry.k3s.example.com/v2/_catalog | jq

# List tags available regarding an image
curl https://registry.k3s.example.com/v2/myhaproxy/tags/list

# list index catalog - with user/password
curl https://registry-admin:<PWD>@registry.k3s.example.com/v2/_catalog | jq

# list index catalog - when you need to specify the CA 
curl -u user:password https://<url>:<port>/v2/_catalog --cacert ca.crt | jq

# list index catalog - for OCP 
curl -u user:password https://<url>:<port>/v2/ocp4/openshift4/tags/list | jq

# Login to registry with podman
podman login -u registry-admin -p <PWD> registry.k3s.example.com
 
# Push images in the registry
skopeo copy "--dest-creds=registry-admin:<PWD>" docker://docker.io/goharbor/harbor-core:v2.6.1 docker://registry.k3s.example.com/goharbor/harbor-core:v2.6.1
```
 

## Install a Local private docker registry

* Change Docker Daemon config to allow insecure connexion with your ip

```bash
ip a
sudo vi /etc/docker/daemon.json
```

```json
{
"insecure-registries": ["192.168.1.11:5000"]
}
```

```bash
sudo systemctl restart docker
docker info
```

Check docker config 
```bash
docker info
```

```ini
.../...
Registry: https://index.docker.io/v1/
Labels:
Experimental: false
Insecure Registries:
192.168.1.11:5000
127.0.0.0/8
Live Restore Enabled: false
```

* Create a volume to store images 

```bash
docker volume create registry
docker volume ls
```

* Run docker registry

```bash
# Launch
docker run -d -p 5000:5000 --restart=always --name registry -v registry:/var/lib/registry registry:2.7

# Check
docker ps

CONTAINER ID IMAGE COMMAND CREATED
STATUS PORTS NAMES
b842ba9788a1 registry:2.7 "/entrypoint.sh /etc…" 5
seconds ago Up 4 seconds 0.0.0.0:5000->5000/tcp registry
```

* Push a images in this registry 

```bash
# Retag and push
docker tag myhaproxy 192.168.1.11:5000/myhaproxy
docker images
docker push 192.168.1.11:5000/myhaproxy
```

* Get catalog and tags from a Registry

```bash
# Check individual 
curl 192.168.1.11:5000/v2/_catalog
curl 192.168.1.11:5000/v2/myhaproxy/tags/list

# Get a list of all images:tags 
for i in $(curl -sk https://registry.example.com/v2/_catalog | jq -r '.repositories[]'); 
do 
  for tag in $(curl -sk https://registry.example.com/v2/${i}/tags/list | jq -r '.tags[]'); 
    do echo ${i}/${tag}; 
  done; 
done

# Podman/Docker pull
for i in $(curl -sk https://registry.example.com/v2/_catalog | jq -r '.repositories[]'); 
do 
  for tag in $(curl -sk https://registry.example.com/v2/${i}/tags/list | jq -r '.tags[]'); 
    do podman pull --tls-verify=false registry.example.com/${i}:${tag};
  done; 
done

# Test if manifest is valid
for i in $(curl -sk https://registry.example.com/v2/_catalog | jq -r '.repositories[]'); 
do 
  for tag in $(curl -sk https://registry.example.com/v2/${i}/tags/list | jq -r '.tags[]'); 
    do curl -sk https://registry.example.com/v2/${i}/manifests/${tag};
  done; 
done
```
