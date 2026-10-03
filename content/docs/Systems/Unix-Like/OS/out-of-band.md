---
date: 2023-08-09T21:00:00+08:00
title: 🖥 Out-of-Band Management
nav_weight: 60 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
---

**Out-of-band management** refers to accessing and controlling a server (console, power on/off, BIOS, remote media) through a dedicated management channel that is *separate from* the normal data path. "In-band" means going through the OS and its network interface; "out-of-band" uses an independent controller (a BMC — Baseboard Management Controller) with its own network port, so it still works even when the OS is down, the machine is hung, or the network stack is broken. RSA is one vendor/technology family of out-of-band access.

## RSA — Remote Solution Administration

Not to be confused with RSA (*Remote Secure Access* = VPN keys and algorithm).

RSA is a connection to the chassis console:

* **ILO** card (GUI) — made by HP, to be plugged into any type of server.
* **OA** (Onboard Administration) — for HP chassis.
* **iDRAC** (GUI) — made by Dell.
* **MMC** / **IMM** — for IBM.
* **ALOM**, **ILOM**, **LOM**, etc. — for Solaris.