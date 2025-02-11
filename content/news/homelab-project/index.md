---
type: news 
title: 🚀  The Homelab Journey
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
  - Hardware
  - Devops
authors:
  - mozebaltyk
images: [./homelab-project/carousel.webp]
---

A journey to my homelab...

<!--more-->

Let expose the problem, I need a homelab, of course on budget. My wife won't let me spend 5000$ in hardware just for house heating. First talk with my friend: "Ah you need a good NAS and a NUC!".
Ok, so the NAS have no CPU power but the NUC have it, the NUC does not have enough disks. What about playing with cluster technologies ? "Oh, then install proxmox!", Yep. but what the purpose to do virtualisation when there is no redondancy ?
So, Let's find out, if there is not another setup possible which will be more or less at the same price than a NAS + NUC.

### First the hardware

Let's study three possible setup with a rough estimate of the costs for each setup:

| Setup            | Components                        | Approximate Price |
|------------------|-----------------------------------|-------------------|
| NAS + NUC        | NAS (e.g., Synology DS220+)       | $300              |
|                  | NUC (e.g., Intel NUC 11)          | $400              |
|                  | Total                             | **$700**          |
|------------------|-----------------------------------|-------------------|
| Raspberry Pi     | 3 x Raspberry Pi 5                | $360 ($120 each)  |
|                  | 3x Hat GeeekPi P33 M.2 NVME + POE | $120 ($40 each)   |
|                  | 3x NVME M2  (cases, SD cards)     | $300 ($100 each)  |
|                  | Total                             | **$780**          |
|------------------|-----------------------------------|-------------------|
| 3 mini PCs       | 3 x Mini PC (e.g., Beelink)       | $600 ($200 each)  |
|                  | 3 x 32GB RAM                      | $300 ($100 each)  |
|                  | 3 x NVME 250GB                    | $600 ($200 each)  |
|                  | Total                             | **$1500**         |

### What would I install on it...
