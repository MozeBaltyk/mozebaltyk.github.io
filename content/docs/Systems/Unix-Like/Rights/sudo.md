---
date: 2023-08-15T21:00:00+08:00
title: 🛡️ sudo
nav_weight: 20 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
---

## /etc/sudoers

The `/etc/sudoers` file contains the set of UNIX operating-system privileges that the local administrator has granted to UNIX users.

**In no case** should this file be edited directly with `vi`; it must be edited with `visudo`.

```bash
sudo          :  execute a command as root.
sudo su       :  become root and stay root.
sudoers       :  file listing the commands allowed for certain users as the superuser (or another user).
visudo -cs    :  strict syntax check of the sudoers file.
```

* `sudo -i` is equivalent to `su -` in terms of rights.
  * with `sudo -i`, the user password is asked.
  * with `su -`, the root password is asked.

## Verification

```bash
sudo -l -U <user>
```

## Rules

```bash
# "user" runs "sudo -u target All_the_commands"
user server=(target) NOPASSWD: ALL
```

### With aliases

```bash
Host_Alias LOAD_BALANCERS = server1,server2

Cmnd_Alias SET_VIP = \
/sbin/ip addr add 192.168.10.12/20 broadcast 192.168.15.255 dev eth0 label eth0\:0, \
/sbin/ip addr del 192.168.10.12/20 dev eth0, \
/sbin/arping -U -c 1 -I eth0 192.168.10.12

loaduser  LOAD_BALANCERS=(root) NOPASSWD: SET_VIP
syncuser  LOAD_BALANCERS=(root) NOPASSWD: SET_VIP
```