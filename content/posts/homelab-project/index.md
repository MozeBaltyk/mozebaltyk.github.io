---
title: 🚀 A journey to my homelab.
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

> [!IMPORTANT]
> I wrote this article before the RAM shortage due to high AI demand. But even after refreshing the figures, my assumption is still valid. 

Let expose the problem, I need a homelab, of course on budget. My wife won't let me spend 5000$ in hardware just for house heating. First talk with my friend: "Ah you need a good NAS and a NUC!".
Ok, so the NAS have no CPU power but the NUC have it, the NUC does not have enough disks space but the NAS have it. What about playing with cluster technologies ? "Oh, then install proxmox!", Yep. but what the purpose to do virtualisation when there is no redondancy ?
So, Let's find out, if there is not another setup possible which will be more or less at the same price!

## First the hardware

Let's study three possible setup with a rough estimation about costs:

| Setup | Components | Approximate Price | Pros | Cons |
|---|---|---|---|---|
| **NAS + NUC** | NAS (e.g., Synology DS225+) | $350–400 | Low power consumption | Not modular |
| | Used NUC 11 i5, 16 GB RAM, 500 GB SSD | $300–400 | Compact | No high availability |
| | 2× NAS HDD – 2 TB | $160–220 ($80–110 each) | Simple to maintain | Limited extensibility |
| | **Total** | **$810–1,020** | | |
| **Raspberry Pi** | 3× Raspberry Pi 5 – 16 GB RAM | $915 ($305 each) | Low power consumption | Limited CPU resources |
| | 3× GeeekPi P33 M.2 NVMe + PoE HAT | $120–150 ($40–50 each) | Compact | Poor CPU-to-price ratio |
| | 3× NVMe M.2 – 500 GB | $240–375 ($80–125 each) | Supports high availability | ARM compatibility limitations |
| | 3× SD cards – 64 GB | $30–45 | Extensible | |
| | PoE switch – 1 Gb / 8 ports | $60–100 | Modular | |
| | Others (cases, cables, etc.) | $50–60 | | |
| | **Total** | **$1,415–1,645** | | |
| **3 Mini PCs – G4** | 3× used HP Mini G4 i5, 32 GB RAM and 500 GB SSD each | $750–900 | Low power consumption | More complicated cable management |
| | Switch – 1 Gb / 8 ports | $30–50 | Supports high availability | Takes more space |
| | Others (cables, etc.) | $40–60 | Modular and extensible | Limited GPU expansion |
| | **Total** | **$820–1,010** | | |
| **3 Mini PCs – G6** | 3× used HP Mini G6 i5, 32 GB RAM and 500 GB SSD each | $1,050–1,250 | Low power consumption | More complicated cable management |
| | Switch – 1 Gb / 8 ports | $30–50 | Supports high availability | 2.5 GbE requires compatible hardware |
| | Others (cables, etc.) | $40–60 | Newer CPU, optional Flex IO 2.5 GbE | Limited GPU expansion |
| | **Total** | **$1,120–1,360** | | |

These are approximate US prices before tax and shipping, checked in October 2026. The NAS, Raspberry Pi hardware, storage, and networking components are priced new; the NUC and Mini PCs are assumed to be complete second-hand or refurbished systems. Used-system prices vary with CPU, memory, storage, condition, and warranty. High availability requires appropriate cluster software, quorum and storage configuration; it isn't guaranteed simply by having three nodes.

The Raspberry Pi cluster is now the most expensive option because of the 16 GB board price and the additional storage, PoE, and cooling hardware. Used G4 Mini PCs currently offer the best CPU/RAM-to-price ratio, while G6 systems cost more but provide newer CPUs and better expansion options.

You could also choose more powerful configurations, such as *Core i7* processors, or newer models such as the *HP EliteDesk 800 G6 Mini*, which can support an optional 2.5 GbE network interface via a compatible Flex IO module.

A fourth option would be to use actual bare-metal servers. If you have access to inexpensive electricity and have the budget, this could be worth considering. However, we won't explore that option in this article.

The main point is that **a cluster of three Mini PCs can be an affordable, flexible, and enjoyable homelab setup**, particularly for experimenting with Proxmox, Kubernetes, distributed storage, and high availability.

I'm not including SFF desktops in this comparison. While an SFF PC may have a power supply rated around 300 W, that doesn't mean it continuously consumes 300 W. Actual power usage depends on the workload and installed components. SFF systems offer better PCIe and GPU expandability, but those advantages may not justify the additional space and potential power consumption for a compact homelab.

At higher budgets, compact alternatives such as the *Minisforum MS-A2* may also be worth considering.

A quick glance at the CPU/RAM-to-price ratio:

| Setup             | CPU (Cores) | RAM   | CPU TDP |Max-load Power Estimate |
|-------------------|-------------|-------|---------|------------------------|
| NAS + NUC         | 6           | 18 GB | 43 W    |90 W                    |
| 3× Raspberry Pi 5 | 12          | 48 GB | N/A     |55 W                    |
| 3× HP Mini G4     | 18          | 96 GB | 105 W   |167 W                   |
| 3× HP Mini G6     | 18          | 96 GB | 105 W   |188 W                   |


## What would I install on it...

A kubernetes of course but which one k3s, rke2, OKD... for now, it's hard to say. My first though was k3s since there is so many example already out there, well documented like [Picluster](https://picluster.ricsanfre.com/docs/home/),
[Khue's Homelab](https://homelab.khuedoan.com/) or [rpi4cluster](https://rpi4cluster.com/). K3s is lightweight but what I see usually is that you add stuff on it like *cilium*, *ingress-nginx*, etc. at the end, they were building a *rke2*... That's why I went directly to *rke2* with an Ansible Collection to deploy it with some customizations through the project named [Rkub](https://github.com/MozeBaltyk/Rkub).

OKD/Openshift also have is homelab but not on bare-metal, mostly KVM or Proxmox like this [one](https://github.com/amrut-asm/homelab) or this [one](https://github.com/sawa2d2/k8s-on-kvm). So in parallel, I also started a Terraform project to deploy OKD, named [Okub](https://github.com/MozeBaltyk/Okub).

About the gitops methods to autodeploy, this could be a nice inspiration: [hivenetes/bootstrapper](https://github.com/hivenetes/k8s-bootstrapper/)

Let's see where I will arrive with those projects... 

## The Goal


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
