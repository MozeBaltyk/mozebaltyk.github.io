---
date: 2023-08-01T21:00:00+08:00
title: 🐳 Docker
navWeight: 60 # Upper weight gets higher precedence, optional.
series:
  - Devops
categories:
  - Docs
tags:
  - Container
---


```bash
# see images available on your hosts
docker image list

# equal to above
docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
httpd               latest              6fa26f20557b        45 hours ago        164MB
hello-world         latest              75280d40a50b        4 months ago        1.69kB

# give sha
docker images --no-trunc=true

# delete unused images 
docker rmi $(docker images -q)    
# delete images without tags
docker rmi $(docker images | grep "^<none>" | awk '{print $3}')
```
