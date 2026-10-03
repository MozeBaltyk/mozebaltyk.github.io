---
date: 2023-08-17T21:00:00+08:00
title: 👤 Users & Connections
nav_weight: 40 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
---

## Investigate a user

```bash
last              # the last user connections to a server (based on /var/log/wtmp or btmp).
ac -d             # statistics of my connection time per day.
ac -p <user>      # the connection time of all users (or of a specific user).
finger            # who is connected (-l to also see mails and plans of all users).
w                 # who is connected, doing what, and how much CPU they use.
who               # who is connected (-u for more info: PID, etc.).
who am i          # with which login I am connected.
id -a             # all info about the user I'm connected as (more precise than "who am i").
logname           # the login name of the current account.
```

## Reboots & uptime

```bash
last reboot   # see all the reboots that took place.
uptime        # see how long the server has been up + the load average.
lslogins -L   # also shows whether a user shutdown/rebooted the machine.
```