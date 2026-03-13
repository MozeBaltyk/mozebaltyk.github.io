---
date: 2023-08-01T21:00:00+08:00
title: 😍 Install KVM
navWeight: 10 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Virtualisation
  - KVM
---

## Prerequisites



### install KVM on RHEL 

```bash
# pre-checks hardware for intel CPU
egrep -c '(vmx|svm)' /proc/cpuinfo 
lscpu | grep Virtualization
lsmod | grep kvm

# on RHEL9 Workstation
sudo dnf install virt-install virt-viewer -y
sudo dnf install -y libvirt
sudo dnf install virt-manager -y
sudo dnf install -y virt-top libguestfs-tools guestfs-tools
sudo gpasswd -a $USER libvirt

# Helper
sudo dnf -y install bridge-utils

# Start libvirt
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo systemctl status libvirtd
```

### install KVM on Ubuntu

```BASH
sudo apt update && sudo apt upgrade -y
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients libvirt-daemon virtinst -y
sudo usermod -aG libvirt $(whoami)
sudo usermod -aG kvm $(whoami)

# Helper
sudo apt install bridge-utils cpu-checker -y

# Start libvirt
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo systemctl status libvirtd
```

* Bonus point:

```BASH
sudo apt install cockpit cockpit-machines -y
sudo systemctl enable --now cockpit.socket
systemctl status cockpit.socket
```

Then manage your VMs from cockpit: https://localhost:9090 which could be an good alternative to `virt-manager`.

