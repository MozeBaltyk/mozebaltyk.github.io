---
date: 2023-08-01T21:00:00+08:00
title:  🚠 Quay.io
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Registry
categories:
  - Devops
---

### Deploy a Quay.io / Mirror-registry on container

Nothing original, it just the documentation of redhat, but can be usefull to kickstart a registry.

```bash
mirror="https://mirror.openshift.com/pub/openshift-v4/clients"
wget ${mirror}/mirror-registry/latest/mirror-registry.tar.gz

tar zxvf mirror-registry.tar.gz

sudo ./mirror-registry install \
  --quayHostname quay01.example.local \
  --quayRoot /opt

podman login -u init \
  -p 7u2Dm68a1s3bQvz9twrh4Nel0i5EMXUB \
  quay01.example.local:8443 \
  --tls-verify=false

# Get IP
sudo podman inspect --format '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' quay-app

#unistall 
sudo ./mirror-registry uninstall -v \
  --quayRoot <example_directory_name>


sudo ./mirror-registry install \
  --quayHostname quay01.example.local \
  --quayRoot /srv \
  --sslCert quay01.example.local.cer \
  --sslKey quay01.example.local.pem

curl -u init: https://quay01.example.local:8443/v2/_catalog | jq
curl -u root:password https://<url>:<port>/v2/ocp4/openshift4/tags/list | jq
```


### Source 

[Mirror-registry](https://docs.openshift.com/container-platform/4.10/installing/disconnected_install/installing-mirroring-creating-registry.html#mirror-registry-localhost_installing-mirroring-creating-registry)

[PULL/PUSH](https://access.redhat.com/documentation/en-us/red_hat_quay/3.8/html-single/deploy_red_hat_quay_for_proof-of-concept_non-production_purposes/index#push_and_pull_images)
