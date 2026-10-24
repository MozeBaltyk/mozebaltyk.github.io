---
title: 🚀 A journey to my homelab. - Part 1
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
  - carousel/homelab-part1.jpg
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

A quick glance at the CPU/RAM/Power-to-prize ratio:

| Setup                   | CPU (Cores:Threads) | RAM   | Max-load Power Estimate | Price   |
|-------------------------|---------------------|-------|-------------------------|---------|
| NAS + NUC               | 6 : 10              | 18 GB | 90 W                    | $900    |
| 3× Raspberry Pi 5       | 12 : 12             | 48 GB | 55 W                    | $820    |
| 3× HP Mini G4 (i5-8th)  | 18 : 18             | 96 GB | 195 W                   | ~$1000  |
| 3× HP Mini G6 (i5-10th) | 18 : 36             | 96 GB | 195 W                   | ~$1300  |


## Which Platform?

### 1. RKE2 / Ubuntu

**Pros:**
- Standard, well-known Linux distribution and Kubernetes architecture.
- Most administrators know how to inspect and troubleshoot Ubuntu servers.
- Broad hardware, driver, storage, and networking compatibility.
- Large ecosystem, extensive documentation, and community support.
- Flexible customization and integration with existing infrastructure.
- Familiar debugging tools (`systemctl`, `journalctl`, `tcpdump`, etc.).
- RKE2 provides a security-focused Kubernetes distribution.

**Cons:**
- Requires OS hardening, patching, and ongoing security management.
- Larger attack surface compared to minimal, purpose-built operating systems.
- Potential configuration drift between nodes.
- OS and Kubernetes upgrades require coordinated lifecycle management.
- Greater operational responsibility for the underlying hosts.

### 2. Talos Linux

**Pros:**
- Immutable, minimal, purpose-built Kubernetes operating system.
- Small attack surface and security-first architecture.
- Declarative, API-driven configuration and management.
- No traditional SSH access or general-purpose package manager.
- Consistent node configuration reduces configuration drift.
- Integrated OS and Kubernetes lifecycle management.
- Suitable for reproducible, automated infrastructure.

**Cons:**
- Different operational model and steeper learning curve.
- Troubleshooting depends on `talosctl`, APIs, and supported diagnostics.
- Less flexibility for installing custom host packages or agents.
- Hardware and driver support is constrained by the Talos kernel and extensions.
- Some existing monitoring, security, and storage tools may require adaptation.
- Smaller ecosystem than Ubuntu-based Kubernetes deployments.


### 3. OKD / Fedora CoreOS

**Pros:**
- Immutable-style, container-focused operating system with transactional updates.
- Integrated Kubernetes platform with Operators and declarative management.
- Automated node configuration through the Machine Config Operator.
- Coordinated platform and OS lifecycle management.
- Built-in authentication, routing, monitoring, and cluster administration capabilities.
- Consistent node configuration reduces drift.
- Strong platform standardization and automation.

**Cons:**
- More complex architecture and additional platform components.
- Higher baseline resource consumption than lightweight Kubernetes distributions.
- More opinionated networking, ingress, storage, and cluster configuration.
- Steeper learning curve for administrators unfamiliar with OpenShift.
- Less flexibility for direct host customization.
- Troubleshooting often requires knowledge of OpenShift-specific components and Operators.
- Version compatibility and upgrades depend on the supported OKD release lifecycle.

### Conclusion for My Homelab

**RKE2 / Ubuntu** — If my homelab were also a general-purpose Linux environment, with VMs, custom drivers, debugging tools, stuff running outside Kubernetes, etc., why not? But it's probably not the best choice for my use case.

**Talos** — If I want reproducible Kubernetes nodes, minimal OS maintenance, a GitOps-oriented approach, and the ability to rebuild nodes easily, this is the one. [This article](https://schoenwald.aero/posts/2026-07-26_from-ubuntu-to-talos/#why-i-used-ubuntu-in-the-first-place) helped me understand the benefits of Talos over Ubuntu/RKE2.

**OKD** — If my goal, besides homelabbing, is to learn OpenShift, Operators, MachineConfig, Routes, OAuth, and enterprise-style platform operations, then OKD is the way to go.

**Conclusion of the Conclusion:** 

In my case, **Talos would probably be the most rational choice**. But since I also want to learn OpenShift for professional reasons, **I'm going with OKD**.

It's not a marriage, though. I'm not ruling out switching to Talos later on.
