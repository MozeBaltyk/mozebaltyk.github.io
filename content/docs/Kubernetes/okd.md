---
date: 2023-08-01T21:00:00+08:00
title: 🐠 OKD
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Devops
categories:
  - Docs
tags:
  - Kubernetes
  - Infrastructure
---

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

## Install bare-metal

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
