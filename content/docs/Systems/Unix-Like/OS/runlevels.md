---
date: 2023-08-16T21:00:00+08:00
title: 🔁 Runlevels & Shutdown
nav_weight: 30 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
---

## Shutdown / reboot

| | Solaris | Red Hat | Ubuntu / Debian | HP-UX | AIX |
|---|---|---|---|---|---|
| **Power down** | `shutdown -i5 -g0 -y` | `shutdown -h` | `shutdown -h` | `shutdown -h now` | `shutdown -F` |
| **Reboot** | `shutdown -i6 -g0 -y` | `shutdown -r` | `shutdown -r` | `shutdown -r now` | `shutdown -Fr` |
| **OK prompt** | `shutdown -i0 -g0 -y` | — | — | — | — |
| **Fast** | `reboot -- -r` (reconfigure) | `shutdown -f` (no fsck) | `shutdown -P` (power off) | `shutdown -F` (force fsck) | — |
| **Force fsck** | `touch /reconfigure` | `touch /forcefsck` | edit `/etc/default/rcS` → `FSCKFIX=yes` | — | — |

## Change runlevel

| Tool | Solaris | Red Hat | Ubuntu / Debian | HP-UX | AIX |
|---|---|---|---|---|---|
| `halt` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `init` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `poweroff` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `reboot` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `shutdown` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `telinit` | ✅ | ✅ | ✅ | — | ✅ |
| `uadmin` | ✅ | — | — | — | — |

## Runlevels

{{< table-snippet "systems/unix-like/runlevels" "Level,Solaris,Red Hat,Ubuntu / Debian,HP-UX,AIX" >}}

## Change the default runlevel

* Solaris / Red Hat / HP-UX / AIX : edit the `initdefault` line in `vi /etc/inittab`.
* Ubuntu / Debian : edit `vi /etc/event.d/rc-default`.

{{< bs/alert info >}}
{{< markdownify >}}
On **systemd** systems (RHEL 7+, Ubuntu 15+), the SysV runlevels are replaced by *targets* — e.g. `systemctl isolate multi-user.target` (runlevel 3), `systemctl isolate graphical.target` (runlevel 5), `systemctl set-default multi-user.target`. See the **Systemd** page.
{{< /markdownify >}}
{{< /bs/alert >}}