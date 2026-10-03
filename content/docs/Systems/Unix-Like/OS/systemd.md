---
date: 2025-01-01T21:00:00+08:00
title: ⚙️ Systemd
nav_weight: 20 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
---

`systemd` replaces the SysV `init` system: services are managed with `systemctl`,
and runlevels map to *targets*.

```bash
systemctl status <unit>                   # status of a service.
systemctl start|stop|restart <unit>      # run / stop / restart.
systemctl enable|disable <unit>          # start at boot (or not).
systemctl isolate multi-user.target      # equivalent of runlevel 3.
systemctl set-default multi-user.target  # change the default target.
systemctl get-default
```

See the **Runlevels & Shutdown** page for the classic runlevel table.
