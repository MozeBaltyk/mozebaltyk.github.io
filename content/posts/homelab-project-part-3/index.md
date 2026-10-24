---
title: 🚀 A journey to my homelab. - Part 3
description: "A journey to my homelab..."
date: 2026-10-20T03:48:10+02:00
noindex: false
featured: true
draft: true
comment: true
toc: true
reward: true
pinned: false
series:
  - Homelab Journey 
categories:
  - Reflection
tags:
  - Homelab
authors:
  - mozebaltyk
images: 
  - carousel/homelab-project.jpg
sidebar: false
---

## What would I install on it...

A kubernetes of course but which one k3s, rke2, OKD... for now, it's hard to say. My first though was k3s since there is so many example already out there, well documented like [Picluster](https://picluster.ricsanfre.com/docs/home/),
[Khue's Homelab](https://homelab.khuedoan.com/) or [rpi4cluster](https://rpi4cluster.com/). K3s is lightweight but what I see usually is that you add stuff on it like *cilium*, *ingress-nginx*, etc. at the end, they were building a *rke2*... That's why I went directly to *rke2* with an Ansible Collection to deploy it with some customizations through the project named [Rkub](https://github.com/MozeBaltyk/Rkub).

OKD/Openshift also have is homelab but not on bare-metal, mostly KVM or Proxmox like this [one](https://github.com/amrut-asm/homelab) or this [one](https://github.com/sawa2d2/k8s-on-kvm). So in parallel, I also started a Terraform project to deploy OKD, named [Okub](https://github.com/MozeBaltyk/Okub).

About the gitops methods to autodeploy, this could be a nice inspiration: [hivenetes/bootstrapper](https://github.com/hivenetes/k8s-bootstrapper/)

Let's see where I will arrive with those projects... 

## Other hardware consideration

For the SSD, NAND TLC and TBW of 600 is the best. TBW represent the number of cycle the SSD can be full, and it give an life plain time of around 5 years. NAND TLC (Triple-Level Cell) = Each memory cell stores 3 bits of data, and bring enough performance for a homelab. 

For the RAM, 

## Roadmap


## Sources 

### Code
* [Khue's Homelab](https://homelab.khuedoan.com/)
* [Khue's Cloudlab](https://github.com/khuedoan/cloudlab)
* [OneDrop](https://github.com/onedr0p/home-ops)
* [rpi4cluster](https://rpi4cluster.com/)
* [Picluster](https://picluster.ricsanfre.com/docs/home/)
* [Angelnu](https://github.com/angelnu/k8s-gitops)
* [Amrut](https://github.com/amrut-asm/homelab)
* [sawa2d2](https://github.com/sawa2d2/k8s-on-kvm)
* [hivenetes/bootstrapper](https://github.com/hivenetes/k8s-bootstrapper/)
* [Talos homelab](https://github.com/prateekjaindev/homelab)

### Hardware
* [Jakub Homelab](https://www.linkedin.com/pulse/building-multi-node-homelab-economy-jakub-hovorka-trepe/)
* [Raspberry Pi 5 pricing](https://www.raspberrypi.com/products/raspberry-pi-5/)
* [Synology DiskStation DS225+](https://www.synology.com/en-us/products/DS225+)
* [Used HP EliteDesk 800 Mini G4 prices](https://www.hardwarehoard.com/prices/hp-elitedesk-800-g4-mini)
* [Used HP EliteDesk 800 Mini G6 prices](https://www.hardwarehoard.com/prices/hp-elitedesk-800-g6-mini)
* [500 GB NVMe price tracker](https://rampricehistory.com/ssd/us/500gb-nvme)
