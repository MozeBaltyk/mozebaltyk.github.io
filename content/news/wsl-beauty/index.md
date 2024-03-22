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

WSL stand for *Windows Subsystem Linux*. It allow us to get the best of both world...

<!--more-->

## Get Started 

Of course, As admin in an powershell:

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
  - `Alt Shift`   +    :  split vertical
  - `Alt shit`    -    :  split horizontal
  - `Alt arrow`        :  to change panel
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