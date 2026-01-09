---
date: 2023-08-27T21:00:00+08:00
title: 🔍️ Investigate
navWeight: 530 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Systems
  - Unix-Like
  - Investigate
---

## Ressources

```bash
# in crontab or tmux session - take every hour a track of the memory usage
for i in {1..24} ; do echo -n "===================== " ; date ; free -m ; top -b -n1 | head -n 15 ; sleep 3600; done >> /var/log/SYSADM/memory.log &
```

## Hardware



## Logs 



## Health Checks


