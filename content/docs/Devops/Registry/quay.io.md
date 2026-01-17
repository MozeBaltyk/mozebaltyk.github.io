---
date: 2023-08-01T21:00:00+08:00
title:  🚠 Quay.io
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - Devops
tags:
  - Registry
  - Containers
---

### Deploy a Quay.io / Mirror-registry on container

Nothing original, it just the documentation of redhat, but can be usefull to kickstart a registry.

Prerequisites:
- 10G /home
- 15G /var
- 300G /srv or /opt (regarding QuayRoot)
- min 2 or more vCPUs.
- min 8 GB of RAM.

```bash
# packages 
sudo yum install -y podman
sudo yum install -y rsync
sudo yum install -y jq

# Get tar
mirror="https://mirror.openshift.com/pub/openshift-v4/clients"
wget ${mirror}/mirror-registry/latest/mirror-registry.tar.gz
tar zxvf mirror-registry.tar.gz

# Get oc-mirror
curl https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/oc-mirror.rhel9.tar.gz -O

# Basic install 
sudo ./mirror-registry install \
  --quayHostname quay01.example.local \
  --quayRoot /opt

# More detailed install
sudo ./mirror-registry install \
  --quayHostname quay01.example.local \
  --quayRoot /srv \
  --quayStorage /srv/quay-pg \
  --pgStorage /srv/quay-storage \
  --sslCert tls.crt \
  --sslKey tls.key

podman login -u init \
  -p 7u2Dm68a1s3bQvz9twrh4Nel0i5EMXUB \
  quay01.example.local:8443 \
  --tls-verify=false

# By default login go in:
cat $XDG_RUNTIME_DIR/containers/auth.json 

# Get IP
sudo podman inspect --format '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' quay-app

#unistall 
sudo ./mirror-registry uninstall -v \
  --quayRoot <example_directory_name>

# Info
curl -u init:password https://quay01.example.local:8443/v2/_catalog | jq
curl -u root:password https://<url>:<port>/v2/ocp4/openshift4/tags/list | jq

# Get an example of imageset
oc-mirror init --registry quay.example.com:8443/mirror/oc-mirror-metadata

# Get list of Operators, channels, packages
oc-mirror list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.14
oc-mirror list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.14 --package=kubevirt-hyperconverged
oc-mirror list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.14 --package=kubevirt-hyperconverged --channel=stable
```

### unlock user init/admin

```bash
QUAY_POSTGRES=`podman ps | grep quay-postgres | awk '{print $1}'`

podman exec -it $QUAY_POSTGRES psql -d quay -c "UPDATE "public.user" SET invalid_login_attempts = 0 WHERE username = 'init'"
```

### Source

[Mirror-registry](https://docs.openshift.com/container-platform/4.14/installing/disconnected_install/installing-mirroring-creating-registry.html#mirror-registry-localhost_installing-mirroring-creating-registry)

[PULL/PUSH](https://access.redhat.com/documentation/en-us/red_hat_quay/3.8/html-single/deploy_red_hat_quay_for_proof-of-concept_non-production_purposes/index#push_and_pull_images)
