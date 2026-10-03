---
date: 2023-08-06T21:00:00+08:00
title: 🐧 Unix Families
nav_weight: 10 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
---

## The Unix variants

| Unix proprietary | GNU / Linux | BSD / open source | Mainframe | Virtualisation |
|---|---|---|---|---|
| AIX | Debian | FreeBSD | MVS (IBM) | VMware / VirtualBox |
| HP-UX | Slackware | NetBSD | SCOS (Bull) | Cloud (IaaS) |
| SunOS (BSD fork) → Solaris | SUSE | OpenBSD | | OpenStack (IaaS/SaaS) |
| IRIX (SGI) | Red Hat | FreeBSD → macOS | | |
| | Fedora | | | |
| | openSUSE | | | |
| | CentOS | | | |
| | Ubuntu (Debian) | | | |
| | Mint | | | |

## The Unix families

{{< bs/alert info >}}
{{< markdownify >}}
Early SunOS (1–4) was BSD-derived; from Solaris 2 / SunOS 5 onward it is System V (SVR4) based — hence Solaris is listed under System V while the variants table notes its BSD fork.
{{< /markdownify >}}
{{< /bs/alert >}}

Historically, Unix split into two main branches:

* **BSD** : SunOS, FreeBSD, DEC ULTRIX.
* **System V** (AT&T heritage) : AIX, HP-UX, Solaris.
* A third branch would be the **proprietary Unixes**.

Today, most "Unix-like" systems are **GNU/Linux** — a separate family that adopts System V-style conventions: Debian, Ubuntu, Red Hat, Fedora, SUSE, openSUSE, CentOS, Slackware, Mint.

## Solaris

### Hardware

The hardware can be identified with `uname -a`:

* `uname -a` returns `Sun4u` → no native virtualization (M-1 / M-2 / M-3).
* `uname -a` returns `Sun4v` → native virtualization (T-1 up to T-5; there is a hypervisor notion that enables **LDOM** virtualization).

### Deployment

* **JumpStart** — Solaris technology to deploy servers with a predefined configuration.

### Volume managers

* **SVM** — native Solaris 8.
* **VxVM** — paid.
* **ZFS** — native Solaris 10.