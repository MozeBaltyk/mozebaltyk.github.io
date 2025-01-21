---
type: news 
title: 🎉 The Beauty of WSL
date: 2023-08-08T03:48:10+02:00
featured: true
draft: false
comment: true
toc: true
reward: true
pinned: false
carousel: true
series:
  - Articles
categories:
  - Blog
tags:
  - Windows
  - Devops
authors:
  - mozebaltyk
images: [./wsl-beauty/carousel.webp]
---

WSL stand for *Windows Subsystem Linux*. It allow us to get the best of both Linux and Windows world...

<!--more-->

## Get Started 

Of course, As admin inside a powershell terminal :

```powershell
# Update your WSL first
wsl --update

# Install the distrib you want
wsl --install -d Ubuntu

# Distrib you have to your disposition
wsl --list --online

# List all WSL installed
wsl --list
wsl --list -v

# if needed to reinstall 
wsl --shutdown
wsl --unregister Ubuntu
```

## Windows Terminal 

WSL is your Linux VM on windows, you can also use *Windows Terminal* for your own confort.

Here some shortcut in *Windows Terminal* but not only 😉 :

  - `alt + enter`      :  mode full ecran
  - `ctrl shift t`     :  terminal
  - `ctrl shift n`     :  new windows
  - `ctrl alt 1 2 3`   :  changer de fenetre
  - `Windows + v`      :  see the paste buffer
  - `Alt Shift =`      :  split vertical
  - `Alt shit -`       :  split horizontal
  - `Alt arrow`        :  to change panel
  - `Alt shit arrow`   :  resize panel  
  - `code .`           :  open VSCode from your current directory

## Free some space on your WSL

* checks which directory contains the most data:

```bash
du -h --max-depth 1
```

* Activate Hyper-V module in windows features:  

  Inside the **control-panel** -> Turn windows features on or off -> activate Hyper-v -> restart.  
  This is required to activate optimize-vhd command.  


* Let's shrink - As admin in powershell:

```powershell
wsl --shutdown

#Find ext4.vhdx in \Users\USER\AppData\Local\Packages\
optimize-vhd -Path C:\Users\<USER>\AppData\Local\Packages\AlmaLinuxOSFoundation.AlmaLinux8WSL_xxxxxxxxxxxxxx\LocalState\ext4.vhdx -Mode full
```

## Export/Import your WSL

```powershell
wsl --export AlmaLinux-8 AlmaLinux-8-full.tar.gz
wsl --import AlmaLinux8-full C:\Users\<USER>\AppData\Local\Packages\Alma8-full .\AlmaLinux-8-full.tar
wsl -d AlmaLinux8-full -u <USER> -s
wsl --unregister AlmaLinux8-full

wsl --list -v
```

## Activate Systemd

Need WSL2 and Windows 11, add below line a the top of the file /etc/wsl.conf

```ini
# /etc/wsl.conf
[boot]
systemd=true
```

## Install KVM on WSL

* First you need systemd enable

* inside `%UserProfile%\.wslconfig` :

```ini
[wsl2]
nestedVirtualization=true
```

* restart WSL

```powershell
wsl.exe --shutdown
```

```bash
sudo apt update
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils cpu-checker \
network-manager iptables-persistent linux-headers-generic \
qemu uml-utilities virt-manager git \
wget libguestfs-tools p7zip-full make dmg2img tesseract-ocr \
tesseract-ocr-eng genisoimage vim net-tools screen firewalld libncurses-dev -y
sudo apt install virt-manager
sudo addgroup kvm
sudo adduser `id -un` libvirt
sudo adduser `id -un` kvm
newgrp libvirt
```

## Make podman engine and kind work on WSL2

* Update crun 

```bash
CRUN_VER='1.11.2'

curl -L "https://github.com/containers/crun/releases/download/${CRUN_VER}/crun-${CRUN_VER}-linux-amd64" -o "${HOME}/.local/bin/crun"

chmod +x "${HOME}/.local/bin/crun"

cat << EOF > $HOME/.config/containers/containers.conf
[engine]
cgroup_manager = "cgroupfs"

[engine.runtimes]
crun = [
  "${HOME}/.local/bin/crun",
  "/usr/bin/crun"
]
EOF
```

* Adapt podman general config `/usr/share/containers/containers.conf`

```ini
[engine]
cgroup_manager = "cgroupfs"
events_logger = "journald"

[engine.runtimes]
crun = [
   "/home/ccaron/.local/bin/crun",
   "/usr/bin/crun"
]
```

* Delegate service

```bash
cat << EOF > /etc/systemd/system/user@.service.d/delegate.conf
[Service]
Delegate=yes
EOF
```

* Adapt `%USERPROFILE%\.wslconfig` to systemd in cgroup

```ini
[wsl2]
nestedVirtualization=true
kernelCommandLine = cgroup_no_v1=all systemd.unified_cgroup_hierarchy=1
```
