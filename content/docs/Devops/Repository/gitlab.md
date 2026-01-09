---
date: 2023-08-01T21:00:00+08:00
title: Gitlab
navWeight: 50 # Upper weight gets higher precedence, optional.
nav_icon:
  vendor: bootstrap
  name: gitlab
  color: grey
series:
  - Devops
categories:
  - Docs
tags:
  - Git
  - Repository
  - Registry
---

## Glab CLI 

https://glab.readthedocs.io/en/latest/intro.html

```bash
# add token
glab auth login --hostname mygitlab.example.com
# view fork of dep installer
glab repo view mygitlab.example.com/copain/project
# clone fork of dep installer
glab repo clone mygitlab.example.com/copain/project
```


## Install 

```ini
Optimization 
puma['worker_processes'] = 16
puma['worker_timeout'] = 60
puma['min_threads'] = 1
puma['max_threads'] = 4
puma['per_worker_max_memory_mb'] = 2048
```


## Certificats 

Generate CSR in `/data/gitlab/csr/server_cert.cnf`

```ini
[req]
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = req_ext
prompt = no

[req_distinguished_name]
C   = PL
ST  = Poland
L   = Warsaw
O   = myOrg
OU  = DEV
CN  = gitlab.example.com

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS = gitlab.example.com
IP = 192.168.01.01
```

```bash
# Create CSR
openssl req -new -newkey rsa:2048 -nodes -keyout gitlab.example.com.key -config /data/gitlab/csr/server_cert.cnf  -out gitlab.example.com.csr

openssl req -noout -text -in gitlab.example.com.csr 

# Sign your CSR with your PKI. If you PKI is a windows one, you should get back a .CER file.

# check info:
openssl x509 -text -in gitlab.example.com.cer -noout
```

```bash
### push it in crt/key in Gitlab
cp /tmp/gitlab.example.com.cer cert/gitlab.example.com.crt
cp /tmp/gitlab.example.com.key cert/gitlab.example.com.key
cp /tmp/gitlab.example.com.cer cert/192.168.01.01.crt
cp /tmp/gitlab.example.com.key cert/192.168.01.01.key

### push rootCA in gitlab
cp /etc/pki/ca-trust/source/anchors/domain-issuing.crt  /data/gitlab/config/trusted-certs/domain-issuing.crt
cp /etc/pki/ca-trust/source/anchors/domain-rootca.crt   /data/gitlab/config/trusted-certs/domain-rootca.crt

### Reconfigure 
vi /data/gitlab/config/gitlab.rb
docker exec gitlab bash -c 'update-ca-certificates'
docker exec gitlab bash -c 'gitlab-ctl reconfigure'

### Stop / Start
docker stop gitlab
docker rm gitlab
docker run -d -p 5050:5050 -p 2289:22 -p 443:443 --restart=always \
-v /data/gitlab/config:/etc/gitlab \
-v /data/gitlab/logs:/var/log/gitlab \
-v /data/gitlab/data:/var/opt/gitlab \
-v /data/gitlab/cert:/etc/gitlab/ssl \
-v /data/gitlab/config/trusted-certs:/usr/local/share/ca-certificates \
--name gitlab gitlab/gitlab-ce:15.0.5-ce.0
```


## Health-Checks
```bash
docker exec gitlab bash -c 'gitlab-ctl status'
docker exec -it gitlab gitlab-rake gitlab:check SANITIZE=true
docker exec -it gitlab gitlab-rake gitlab:env:info
```

## Backup  
```bash
docker exec -it gitlab gitlab-rake gitlab:backup:create --trace

#Alternate way to do it 
docker exec gitlab bash -c 'gitlab-backup create'
docker exec gitlab bash -c 'gitlab-backup create SKIP=repositories'
docker exec gitlab bash -c 'gitlab-backup create SKIP=registry'
```

## Restore from a Backup

```bash
Restore
gitlab-ctl reconfigure
gitlab-ctl start
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq
gitlab-ctl status
ls -lart /var/opt/gitlab/backups

docker exec -it gitlab gitlab-rake gitlab:backup:restore --trace
docker exec -it gitlab gitlab-rake gitlab:backup:restore BACKUP=1537738690_2018_09_23_10.8.3 --trace

Restart 
docker exec gitlab bash -c 'gitlab-ctl restart'
```


## Update 

### Pre-checks before update
sudo docker exec -it gitlab gitlab-rake gitlab:check
sudo docker exec -it gitlab gitlab-rake gitlab:doctor:secrets

### Checks the update path 
In functions of your update, checks the path  
https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
14.10.5 -> 15.0.5 -> 15.4.6 -> 15.8.0

On your Workstation: 
```bash
podman pull gitlab/gitlab-ce:15.0.5-ce.0
podman save gitlab/gitlab-ce:15.0.5-ce.0 > sources/gitlab-ce:15.0.5-ce.0.tar
```

Export the tar to the target host
```bash
docker load < /tmp/gitlab-ce:15.0.5-ce.0.tar
docker stop gitlab
docker rm gitlab
docker run -d -p 5050:5050 -p 2289:22 -p 443:443 --restart=always \
-v /data/gitlab/config:/etc/gitlab \
-v /data/gitlab/logs:/var/log/gitlab \
-v /data/gitlab/data:/var/opt/gitlab \
-v /data/gitlab/cert:/etc/gitlab/ssl \
-v /data/gitlab/config/trusted-certs:/usr/local/share/ca-certificates \
--name gitlab gitlab/gitlab-ce:15.0.5-ce.0
```

Becarefull to check in the Admin console that migrations jobs completed successfully before to go to next step
