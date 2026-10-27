---
title: 🚀 A journey to my homelab. - Part 1
description: "A three-node homelab on a budget."
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

Let me state the problem: I need a homelab, of course on a budget. My wife won't let me spend $5,000 in hardware just for house heating. First conversation with my friend: "Ah, you need a good NAS and a NUC!"

Okay, so the NAS has no CPU power but the NUC does; the NUC doesn't have enough disk space but the NAS does. What about playing with cluster technologies? "Oh, then install Proxmox!" Yep. But what's the point of virtualization when there is no redundancy?

So let's find out whether another setup is possible, for more or less the same price.

## First the hardware

Let's study three possible setups with a rough estimate of the costs:

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

A quick glance at the CPU/RAM/Power-to-price ratio:

| Setup                   | CPU (Cores:Threads) | RAM   | Max-load Power Estimate | Price   |
|-------------------------|---------------------|-------|-------------------------|---------|
| NAS + NUC               | 6 : 10              | 18 GB | 90 W                    | $900    |
| 3× Raspberry Pi 5       | 12 : 12             | 48 GB | 55 W                    | ~$1500  |
| 3× HP Mini G4 (i5-8th)  | 18 : 18             | 96 GB | 195 W                   | ~$1000  |
| 3× HP Mini G6 (i5-10th) | 18 : 36             | 96 GB | 195 W                   | ~$1300  |

### Other Hardware Considerations

**SSD: TLC NAND and Endurance**

For storage, I'm leaning toward TLC NAND SSDs with an endurance rating of around 600 TBW for a 1 TB drive.

There are two important specifications to consider:

- **TLC (Triple-Level Cell):** Each NAND memory cell stores 3 bits of data. It provides a good balance between price, performance, and endurance, making it an interesting option for a homelab.
- **TBW (Terabytes Written):** Represents the total amount of data that can be written to an SSD within its rated endurance. For example, a 1 TB SSD rated at 600 TBW can theoretically be rewritten approximately 600 times before reaching that rating.

QLC (Quad-Level Cell) is the cheaper alternative: 4 bits per cell, so more capacity for the same silicon, but its endurance and sustained write speed are a fraction of TLC. It is worth avoiding for anything that writes continuously.

A 600 TBW rating corresponds to roughly 328 GB of writes per day over five years. This doesn't mean the SSD will stop working after five years or after reaching 600 TBW. It's an endurance rating, not an expiration date.

For OKD, storage performance is also important, particularly for **etcd**, which is sensitive to disk latency. The etcd documentation recommends keeping fsync latency below 10 ms, and a DRAM-less or SMR drive can easily miss that under load.

Since the cluster will run continuously, I would rather prioritize reliable TLC storage with good sustained performance than simply look for the highest advertised sequential read and write speeds.

**RAM: Capacity Before Performance**

For RAM, the classic considerations are capacity and frequency. In my case, 32 GB of DDR4 is plenty.

Note that the G4 (i5-8500T) and G6 (i5-10500T) Mini PCs are both officially rated for DDR4-2666, so a 3200 MHz kit simply runs at 2666. Buy on capacity and price, not on the frequency printed on the box.

Timing is the other parameter. A DDR4-3200 kit is typically sold as CL16-18-18-38: the first number (CAS latency) gets the marketing, but the sub-timings matter just as much for real-world latency.

One caveat that does not apply here: desktop RAM kits are validated for a specific platform (EXPO for AMD, XMP for Intel), and mixing them can be hit or miss. The Mini PCs use SO-DIMMs, which carry no XMP/EXPO profiles and run at JEDEC defaults, so there is nothing to tune — a reputable kit is enough.

## Extra hardware

The homelab could be completed with a UPS or a Ugreen NAS for backup.

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
