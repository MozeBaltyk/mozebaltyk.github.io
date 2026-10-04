---
date: 2023-08-01T21:00:00+08:00
title: 🐠 OKD & OpenShift
nav_weight: 90 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Kubernetes
  - IaC
---

## OKD vs OpenShift

They are essentially **the same Kubernetes distribution**.

**OKD** — short for "The Community Distribution of Kubernetes that powers Red Hat OpenShift" — is the free, upstream/community edition: the same codebase, community support, and images pulled from `quay.io`.

**OpenShift** is Red Hat's enterprise product: OKD plus commercial support, certifications, a longer support lifecycle, Red Hat registries (`registry.redhat.io`) and OperatorHub access.

Day-to-day they are nearly interchangeable — both use the same `oc`, `openshift-install` and `oc-mirror` tooling, and the same `install-config.yaml` layout. Unless stated otherwise, the notes below apply to both.

## Install

```bash
# Get latest version
OKD_VERSION=$(curl -s https://api.github.com/repos/okd-project/okd/releases/latest | jq -r .tag_name)

# Download
curl -L https://github.com/okd-project/okd/releases/download/${OKD_VERSION}/openshift-install-linux-${OKD_VERSION}.tar.gz -O
curl -L https://github.com/okd-project/okd/releases/download/${OKD_VERSION}/openshift-client-linux-${OKD_VERSION}.tar.gz -O

# Download FCOS iso
./openshift-install coreos print-stream-json | grep '\.iso[^.]'
./openshift-install coreos print-stream-json | jq .architectures.x86_64.artifacts.metal.formats.iso.disk.location
./openshift-install coreos print-stream-json | jq .architectures.x86_64.artifacts.vmware.formats.ova.disk.location
./openshift-install coreos print-stream-json | jq '.architectures.x86_64.artifacts.digitalocean.formats["qcow2.gz"].disk.location'
./openshift-install coreos print-stream-json | jq '.architectures.x86_64.artifacts.qemu.formats["qcow2.gz"].disk.location'
./openshift-install coreos print-stream-json | jq '.architectures.x86_64.artifacts.metal.formats.pxe | .. | .location? // empty'
```

## Create a cluster

```bash
openshift-install create install-config

openshift-install create manifests

openshift-install create ignition-configs

openshift-install create cluster --dir . --log-level=info
openshift-install destroy cluster --log-level=info
```

## Install bare-metal (IPI)

[Official doc](https://docs.okd.io/4.15/installing/installing_bare_metal_ipi/ipi-install-installation-workflow.html)

```bash
# Pre-tasks
useradd kni
echo "kni ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/kni
chmod 0440 /etc/sudoers.d/kni
su - kni -c "ssh-keygen -t ed25519 -f /home/kni/.ssh/id_rsa -N ''"
sudo dnf install -y libvirt qemu-kvm python3-devel jq
sudo usermod --append --groups libvirt kni
sudo systemctl start firewalld
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --reload
sudo systemctl enable libvirtd --now
sudo virsh pool-define-as --name default --type dir --target /var/lib/libvirt/images
sudo virsh pool-start default
sudo virsh pool-autostart default

# Pull secret (https://console.redhat.com/openshift/install/metal/installer-provisioned)
su - kni
vim pull-secret.txt

# Network
export PUB_CONN="cloud-init eth1"
nmcli con down "$PUB_CONN"
nmcli con delete "$PUB_CONN"
nmcli connection add ifname baremetal type bridge con-name baremetal bridge.stp no
nmcli con add type bridge-slave ifname "$PUB_CONN" master baremetal
nohup bash -c "pkill dhclient;dhclient baremetal" &

# retrieve OKD installer
export VERSION="stable-4.15"
export RELEASE_ARCH="amd64"
export RELEASE_IMAGE=$(curl -s https://mirror.openshift.com/pub/openshift-v4/$RELEASE_ARCH/clients/ocp/$VERSION/release.txt | grep 'Pull From: quay.io' | awk -F ' ' '{print $3}')

# Extract OKD installer
export cmd=openshift-baremetal-install
export pullsecret_file=~/pull-secret.txt
export extract_dir=$(pwd)
curl -s https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$VERSION/openshift-client-linux.tar.gz | tar zxvf - oc
mv oc $HOME/.local/bin
oc adm release extract --registry-config "${pullsecret_file}" --command=$cmd --to "${extract_dir}" ${RELEASE_IMAGE}
mv openshift-baremetal-install $HOME/.local/bin

# Create FCOS image cache (usefull for network with limited bandwidth)
sudo dnf install -y podman
sudo firewall-cmd --add-port=8080/tcp --zone=public --permanent
sudo firewall-cmd --reload

mkdir /home/kni/rhcos_image_cache
sudo semanage fcontext -a -t httpd_sys_content_t "/home/kni/rhcos_image_cache(/.*)?"
sudo restorecon -Rv /home/kni/rhcos_image_cache/

export RHCOS_QEMU_URI=$(openshift-baremetal-install coreos print-stream-json | jq -r --arg ARCH "$(arch)" '.architectures[$ARCH].artifacts.qemu.formats["qcow2.gz"].disk.location')
export RHCOS_QEMU_NAME=${RHCOS_QEMU_URI##*/}
export RHCOS_QEMU_UNCOMPRESSED_SHA256=$(openshift-baremetal-install coreos print-stream-json | jq -r --arg ARCH "$(arch)" '.architectures[$ARCH].artifacts.qemu.formats["qcow2.gz"].disk["uncompressed-sha256"]')
curl -L ${RHCOS_QEMU_URI} -o ./rhcos_image_cache/${RHCOS_QEMU_NAME}

# Validate httpd_sys_content_t
ls -Z ./rhcos_image_cache

# Create pod
podman run -d --name rhcos_image_cache \
-v rhcos_image_cache:/var/www/html \
-p 8080:8080/tcp \
registry.access.redhat.com/ubi9/httpd-24

export BAREMETAL_IP=$(ip addr show dev eth1 | awk '/inet /{print $2}' | cut -d"/" -f1)
export BOOTSTRAP_OS_IMAGE="http://${BAREMETAL_IP}:8080/${RHCOS_QEMU_NAME}?sha256=${RHCOS_QEMU_UNCOMPRESSED_SHA256}"
echo "    bootstrapOSImage=${BOOTSTRAP_OS_IMAGE}"
```

Make an ISO boot USB for bare-metal:

```bash
dd if=$HOME/ocp-latest/rhcos-live.iso of=/dev/sdb bs=1024k status=progress
```

## OC Mirror

* Need at least one Operator:

```yaml
kind: ImageSetConfiguration
apiVersion: mirror.openshift.io/v1alpha2
archiveSize: 4
storageConfig:
  registry:
    imageURL: quay.example.com:8443/mirror/oc-mirror-metadata
    skipTLS: false
mirror:
  platform:
    architectures:
      - "amd64"
    channels:
    - name: stable-4.14
      type: ocp
      shortestPath: true
    graph: true
  operators:
    - catalog: registry.redhat.io/redhat/redhat-operator-index:v4.14
      packages:
        - name: kubevirt-hyperconverged
          channels:
            - name: 'stable'
        - name: serverless-operator
          channels:
            - name: 'stable'
  additionalImages:
  - name: registry.redhat.io/ubi9/ubi:latest
  helm: {}
```

```bash
# install oc-mirror:
curl https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/oc-mirror.rhel9.tar.gz -O

# Get an example of imageset
oc-mirror init --registry quay.example.com:8443/mirror/oc-mirror-metadata

# Find operators in the list of Operators, channels, packages
oc-mirror list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.14
oc-mirror list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.14 --package=kubevirt-hyperconverged
oc-mirror list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.14 --package=kubevirt-hyperconverged --channel=stable

# mirror with a jumphost which online access
oc-mirror --config=imageset-config.yaml docker://quay.example.com:8443

# mirror for airgap
oc-mirror --config=imageSetConfig.yaml file://tmp/download
oc-mirror --from=/tmp/upload/ docker://quay.example.com/ocp/operators

# Refresh OperatorHub
oc get pod -n openshift-marketplace

# Get the index pod and delete it to refresh
oc delete pod cs-redhat-operator-index-m2k2n -n openshift-marketplace
```

## Add node

```bash
export OPENSHIFT_CLUSTER_ID=$(oc get clusterversion -o jsonpath='{.items[].spec.clusterID}')
export CLUSTER_REQUEST=$(jq --null-input --arg openshift_cluster_id "$OPENSHIFT_CLUSTER_ID" '{
  "api_vip_dnsname": "<api_vip>",
  "openshift_cluster_id": $openshift_cluster_id,
  "name": "<openshift_cluster_name>"
}')
```

## Platform in install-config

* Get all info on how to config

```shell
openshift-install explain installconfig.platform.libvirt
```

```yaml
## none
platform:
   none: {}

## baremetal - use ipmi to provision baremetal
platform:
  baremetal:
    apiVIP: 192.168.111.5
    ingressVIP: 192.168.111.7
    provisioningNetwork: "Managed"
    provisioningNetworkCIDR: 172.22.0.0/24
    provisioningNetworkInterface: eno1
    clusterProvisioningIP: 172.22.0.2
    bootstrapProvisioningIP: 172.22.0.3
    hosts:
      - name: master-0
        role: master
        bmc:
          address: ipmi://192.168.111.1
          username: admin
          password: password
        bootMACAddress: 52:54:00:a1:9c:ae
        hardwareProfile: default
      - name: master-1
        role: master
        bmc:
          address: ipmi://192.168.111.2
          username: admin
          password: password
        bootMACAddress: 52:54:00:a1:9c:af
        hardwareProfile: default
      - name: master-2
        role: master
        bmc:
          address: ipmi://192.168.111.3
          username: admin
          password: password
        bootMACAddress: 52:54:00:a1:9c:b0
        hardwareProfile: default

## vpshere - old syntax and deprecated form (new one in 4.15 with "failure domain")
vsphere:
    vcenter:
    username:
    password:
    datacenter:
    defaultDatastore:
    apiVIPs:
    - x.x.x.x
    ingressVIPs:
    - x.x.x.x

## new syntax
platform:
  vsphere:
    apiVIPs:
    - x.x.x.x
    datacenter: xxxxxxxxxxxx_datacenter
    defaultDatastore: /xxxxxxxxxxxx_datacenter/datastore/Shared Storages/ssd-001602
    failureDomains:
     - name: CNV4
      region: fr
      server: xxxxxxxxxxxx.ovh.com
      topology:
        computeCluster: /xxxxxxxxxxxx_datacenter/host/Management Zone Cluster
        datacenter: xxxxxxxxxxxx_datacenter
        datastore: /xxxxxxxxxxxx_datacenter/datastore/Shared Storages/ssd-001602
        networks:
        - vds_mgmt
      zone: dc
    ingressVIPs:
    - x.x.x.x
    password: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    username: admin
    vCenter: xxxxxxxxxxx.ovh.com
    vcenters:
    - datacenters:
      - xxxxxxxxxx_datacenter
      password: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      port: 443
      server: xxxxxxx.ovh.com
      user: admin
```

## Utils

```bash
# Get Cluster ID
oc get clusterversion -o jsonpath='{.items[].spec.clusterID}'

# Get Nodes which are Ready
oc get nodes --output jsonpath='{range .items[?(@.status.conditions[-1].type=="Ready")]}{.metadata.name} {.status.conditions[-1].type}{"\n"}{end}'

# get images from all pods in a namespace
oc get pods -n <namespace> --output jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}'
```

## Set OperatorHub

* in airgap

```bash
oc get catalogsources -n openshift-marketplace
```