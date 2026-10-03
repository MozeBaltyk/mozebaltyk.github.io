---
date: 2023-08-10T21:00:00+08:00
title: 🔍 Find & Inspect Processes
nav_weight: 10 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
---

## Find a process

```bash
ps -fp <pid>        # find a process by its PID.
pidof httpd         # find the PIDs of httpd.
pidstat -lp <pid>   # process name with all its complete arguments.
                    # for a tomcat or weblogic process, you can split the arguments with: sed 's/ -/\n -/g'
pidstat -C "mysql"  # find a process by its name (gives the PID and CPU load).
```

## The process tree

```bash
pstree -pu   # the process tree with PID and user (if pstree is not installed, use the alternatives below).
```

```bash
ps -ejH
  PID  PGID   SID TTY          TIME CMD
    1     1     1 ?        00:00:37 init
11016 11009 11009 ?        00:00:00       sshd
11017 11017 11017 pts/12   00:00:00         bash
11125 11125 11017 pts/12   00:00:00           telnet
```

```bash
ps axjf
 PPID   PID  PGID   SID TTY      TPGID STAT   UID   TIME COMMAND
    0     1     1     1 ?           -1 Ss       0   0:37 init [5]
 8617 10610 10610 10610 ?           -1 Ss       0   0:00  \_ sshd: support [priv]
10610 10710 10610 10610 ?           -1 S     5027   0:00      \_ sshd: support@notty
10710 10711 10711 10711 ?           -1 Ss    5027   0:00          \_ sshd: support@internal-sftp-server
```

```bash
ps faux
USER       PID  %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1   0.0  0.0  10372   696 ?        Ss   Aug09   0:37 init [5]
user1      4168  0.0  0.0   8728   968 ?        Ss   Aug24   0:00  |   \_ /bin/bash -c perl /data/supports/scripts/SRAM_asr5k.pl &>/dev/null
user1      4174  0.0  0.0  34068  5044 ?        S    Aug24   0:00  |       \_ perl /data/supports/SRAM_asr5k.pl
user1      4188  0.0  0.0   8728   984 ?        S    Aug24   0:00  |           \_ sh -c grep -c SRAM /data/syslogCOLLECT/LTE_*/*/*.20160824.log
```

## /proc

The `/proc` filesystem exposes per-process information:

```bash
# stat /proc/22637/
  File: `/proc/22637/'
  Size: 0               Blocks: 0          IO Block: 1024   directory
Device: 3h/3d   Inode: 1935618105  Links: 8
Access: (0555/dr-xr-xr-x)  Uid: ( 1001/ user)   Gid: ( 1001/  users)
Access: 2018-02-11 12:04:54.871001283 +0100
Modify: 2018-02-11 12:04:54.871001283 +0100
Change: 2018-02-11 12:04:54.871001283 +0100
```