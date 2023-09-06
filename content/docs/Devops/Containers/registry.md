---
date: 2023-08-01T21:00:00+08:00
title: 🏭 Registry
navWeight: 100 # Upper weight gets higher precedence, optional.
series:
  - Containers
categories:
  - Devops
---


###  How to use a docker regsitry   

```bash 
# list
curl https://registry.k3s.example.com/v2/_catalog | jq
curl https://registry-admin:<PWD>@registry.k3s.example.com/v2/_catalog | jq

# Login to registry
podman login -u registry-admin -p <PWD> registry.k3s.example.com
 
# Push images in the registry
skopeo copy "--dest-creds=registry-admin:<PWD>" docker://docker.io/goharbor/harbor-core:v2.6.1 docker://registry.k3s.example.com/goharbor/harbor-core:v2.6.1
```
 
