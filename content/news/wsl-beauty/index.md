---
type: news 
title: 🎉 The Beauty of WSL
date: 2023-08-22T03:48:10+02:00
featured: true
draft: true
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


## Free some space
Free some space on your wsl:
du -h --max-depth 1 # checks which directory contains the most data

Activate Hyper-V module in windows features 
(control-panel -> Turn windows features on or off -> activate Hyper-v -> restart). This is required to activate optimize-vhd command.

In an admin powershell :
wsl --shutdown

#Find ext4.vhdx in \Users\USER\AppData\Local\Packages\
optimize-vhd -Path C:\Users\gsusset\AppData\Local\Packages\AlmaLinuxOSFoundation.AlmaLinux8WSL_dx92scvka9p9g\LocalState\ext4.vhdx -Mode full