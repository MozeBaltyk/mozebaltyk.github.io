---
title: 🎉 The Beauty of WSL
description: "WSL stands for Windows Subsystem for Linux. It allows us to get the best of both the Linux and Windows worlds..."
date: 2025-05-01T03:48:10+02:00
noindex: false
featured: true
draft: false
comment: true
toc: true
reward: true
pinned: false
carousel: true
series:
  - Posts
categories:
  - SysAdmin
tags:
  - Windows / WSL
  - Linux
authors:
  - mozebaltyk
images:
  - ./carousel/wsl-beauty.webp
sidebar: false
---

## Get Started

Of course, from an Administrator PowerShell terminal:

```powershell
# Update WSL first
wsl --update

# Install the distribution you want
wsl --install -d Ubuntu

# List the distributions available for installation
wsl --list --online

# List all installed WSL distributions
wsl --list
wsl --list -v

# If needed, reinstall a distribution
wsl --shutdown
wsl --unregister Ubuntu
```

Be careful with `wsl --unregister`: it removes the distribution and its data.

## Windows Terminal

WSL gives you a Linux environment on Windows, and you can also use *Windows Terminal* for a more comfortable command-line experience.

Here are some useful shortcuts in *Windows Terminal* — and a few Windows shortcuts as well 😉:

- `Alt + Enter`: full-screen mode
- `Ctrl + Shift + T`: open a new terminal tab
- `Ctrl + Shift + N`: open a new window
- `Ctrl + Alt + 1/2/3`: switch between configured profiles
- `Windows + V`: open the clipboard history
- `Alt + Shift + =`: split the pane vertically
- `Alt + Shift + -`: split the pane horizontally
- `Alt + Arrow`: switch between panes
- `Alt + Shift + Arrow`: resize the current pane
- `code .`: open VS Code from the current directory

## Free some space on your WSL

* Check which directories contain the most data:

```bash
du -h --max-depth 1
```

* Enable the Hyper-V module in Windows Features:

  Go to **Control Panel** → **Turn Windows features on or off** → enable **Hyper-V** → restart Windows.

  This is required to use the `Optimize-VHD` command.

* Let's shrink the virtual disk. Run PowerShell as Administrator:

```powershell
wsl --shutdown

# Find ext4.vhdx under:
# C:\Users\<USER>\AppData\Local\Packages\

Optimize-VHD -Path C:\Users\<USER>\AppData\Local\Packages\AlmaLinuxOSFoundation.AlmaLinux8WSL_xxxxxxxxxxxxxx\LocalState\ext4.vhdx -Mode Full
```

## Export/Import your WSL

```powershell
wsl --export AlmaLinux-8 AlmaLinux-8-full.tar
wsl --import AlmaLinux8-full C:\Users\<USER>\AppData\Local\Packages\Alma8-full .\AlmaLinux-8-full.tar
wsl -d AlmaLinux8-full -u <USER>
wsl --unregister AlmaLinux8-full

wsl --list -v
```

This is useful if you want to back up a distribution, move it, or recreate it under a different name.

## Activate Systemd

You need WSL 2 and a recent enough WSL version.

Add the following lines at the top of `/etc/wsl.conf`:

```ini
# /etc/wsl.conf
[boot]
systemd=true
```

Then restart WSL:

```powershell
wsl --shutdown
```

## Install KVM on WSL

* First, you need systemd enabled.

* Inside `%USERPROFILE%\.wslconfig`:

```ini
[wsl2]
nestedVirtualization=true
```

* Restart WSL:

```powershell
wsl.exe --shutdown
```

Then install and check KVM support:

```bash
sudo apt update
sudo apt install cpu-checker
sudo kvm-ok

# Basic packages
sudo apt -y install libvirt-daemon-system bridge-utils qemu-kvm libvirt-daemon

# Extra tools
sudo apt install virtinst libosinfo-bin virt-top libguestfs-tools
sudo apt install xsltproc uidmap

# GUI tools
sudo apt -y install qemu-system virt-manager

sudo addgroup kvm
sudo adduser "$(id -un)" libvirt-qemu
sudo adduser "$(id -un)" kvm
newgrp libvirt
```

## Make Podman engine and Kind work on WSL2

* Adapt `%USERPROFILE%\.wslconfig` to use systemd and cgroup v2:

```ini
[wsl2]
nestedVirtualization=true
kernelCommandLine = cgroup_no_v1=all systemd.unified_cgroup_hierarchy=1
```

* Update the UID map and Podman user configuration:

```bash
# Rootless Podman 4.9.3 on WSL2 + Ubuntu 24.04
sudo apt-get install uidmap

echo "ubuntu:100000:2097152" | sudo tee /etc/subuid
echo "ubuntu:100000:2097152" | sudo tee /etc/subgid

mkdir -p "$HOME/.config/containers"

cat << EOF > "$HOME/.config/containers/containers.conf"
unqualified-search-registries=["docker.io"]

[aliases]
"library"="docker.io/library"

[engine]
cgroup_manager = "cgroupfs"
events_logger = "journald"
EOF
```

Replace `ubuntu` with your actual Linux user if needed.

* Install Kind:

```bash
[ "$(uname -m)" = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

## Make WSL use the host network configuration

This is useful when switching between Wi-Fi networks.

Add the following to `%USERPROFILE%\.wslconfig`:

```ini
[wsl2]
networkingMode=mirrored
dnsTunneling=true
autoProxy=true
```

Then restart WSL:

```powershell
wsl --shutdown
```

## Post-scriptum

This article was originally written in **May 2025**, and it reflects the WSL configuration and workarounds I was using at that time.

WSL evolves quickly, so some settings may become unnecessary or enabled by default in newer versions.

In particular:

- systemd support may already be enabled depending on the distribution
- `nestedVirtualization=true` may already be the default on supported systems
- recent Podman versions may work without forcing `cgroupfs`
- cgroup v2 support has improved over time
- WSL networking behavior continues to evolve

So I would treat the commands above as a record of a working setup from that period rather than as a universal configuration for every current WSL installation.

The main idea, however, remains the same:

**WSL is a very practical way to keep a Linux-first workstation while still working inside a Windows environment.**