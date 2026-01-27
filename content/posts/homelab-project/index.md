---
title: 🚀 The Homelab Journey
description: "A journey to my homelab..."
date: 2025-06-01T03:48:10+02:00
noindex: false
featured: true
draft: true
comment: true
toc: true
reward: true
pinned: false
carousel: false
series:
  - Posts 
categories:
  - Homelab 
tags:
  - Hardware
  - Devops
  - Homelab
authors:
  - mozebaltyk
images: 
  - ./carousel/homelab-project.avif
sidebar: false
---

> [!IMPORTANT]
> I wrote this article before the RAM shortage due to high AI demand. 

Let expose the problem, I need a homelab, of course on budget. My wife won't let me spend 5000$ in hardware just for house heating. First talk with my friend: "Ah you need a good NAS and a NUC!".
Ok, so the NAS have no CPU power but the NUC have it, the NUC does not have enough disks space but the NAS have it. What about playing with cluster technologies ? "Oh, then install proxmox!", Yep. but what the purpose to do virtualisation when there is no redondancy ?
So, Let's find out, if there is not another setup possible which will be more or less at the same price!

## First the hardware

Let's study three possible setup with a rough estimation about costs:

| Setup            | Components                        | Approximate Price |
|------------------|-----------------------------------|-------------------|
| NAS + NUC        | NAS (e.g., Synology DS220+)       | $300              |
|                  | NUC (e.g., Intel NUC 11)          | $400              |
|                  | 2x HDD - 2TB                      | $200 ($100 each)  |
|                  | Total                             | **$900**          |
| Raspberry Pi     | 3x Raspberry Pi 5 - 16Gb RAM      | $450 ($150 each)  |
|                  | 3x Hat GeeekPi P33 M.2 NVME + POE | $120 ($40 each)   |
|                  | 3x NVME M2 500GB                  | $120 ($40 each)   |
|                  | 3x SD cards - 64Gb                | $40               |
|                  | Switch POE - 1Gb / 8 ports        | $50               |
|                  | Others (Case, cables, etc )       | $40               |
|                  | Total                             | **$820**          |
| 3 mini PCs       | 3 x Mini PC (e.g., HP mini G4 i5) | $420 ($140 each)  |
|                  | 3 x 32GB RAM                      | $150 ($50 each)   |
|                  | 3 x NVME 500GB                    | $120 ($40 each)   |
|                  | Switch - 1Gb / 8 ports            | $30               |
|                  | Others (Case, cables, etc )       | $40               |
|                  | Total                             | **$760**          |

I repeat but the table above is a rough estimation and about the 3 mini pc, I am talking about second hand pc bought on Ebay. 
But as you can see, there is not a big difference in the price. And you could for other more performant PC like *core i7* or more recent *HP mini G5*. 

About the "NAS + NUC" option:
  - Pros:
        * low-power
        * Compact
  - Cons:
        * Not modular 
        * No High Availibity

About the "Raspberry Pi" option:
  - Pros:
        * low-power
        * Compact
        * High Availibity
        * Modular and extensible
  - Cons:
        * Limited resources

About the "3 mini PCs" option:
  - Pros:
        * low-power
        * High Availibity
        * Modular and extensible
        * More CPU/RAM available
        * The less expensive option
  - Cons:
        * Take a bit more space
        * Cable management a bit more tricky 

Forth options would be with real servers bare-metal, if you have access to cheap energy and have the budget for it, go for it... In the article, we will not dig into this option. But my point here is the "3 mini PCs" option can be much fun option and not so costly for a homelab.

## What would I install on it...

A kubernetes of course but which one k3s, rke2, OKD... for now, it's hard to say. My first though was k3s since there is so many example already out there, well documented like [Picluster](https://picluster.ricsanfre.com/docs/home/),
[Khue's Homelab](https://homelab.khuedoan.com/) or [rpi4cluster](https://rpi4cluster.com/). K3s is lightweight but what I see usually is that you add stuff on it like *cilium*, *ingress-nginx*, etc. at the end, they were building a *rke2*... That's why I went directly to *rke2* with an Ansible Collection to deploy it with some customizations. The project named [Rkub](https://github.com/MozeBaltyk/Rkub).

OKD/Openshift also have is homelab but not on bare-metal, mostly KVM or Proxmox like this [one](https://github.com/amrut-asm/homelab) or this [one](https://github.com/sawa2d2/k8s-on-kvm). So in parallel, I also started a Terraform project to deploy OKD, named [Okub](https://github.com/MozeBaltyk/Okub).

About the gitops methods to autodeploy, this could be a nice inspiration: [hivenetes/bootstrapper](https://github.com/hivenetes/k8s-bootstrapper/)

Let's see where I will arrive with those projects... 

## What it can be for ?

## Roadmap