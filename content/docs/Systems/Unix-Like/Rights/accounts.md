---
date: 2023-08-15T21:00:00+08:00
title: 👥 Users & Groups
nav_weight: 10 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
---

## Configuration files

| File | Check command | Purpose |
|---|---|---|
| `/etc/passwd` | `pwck` | user accounts |
| `/etc/group` | `grpck` | groups |
| `/etc/shadow` | — | password hashes and aging |
| `/etc/gshadow` | — | group passwords |
| `/etc/skel` | — | files installed by default when a user is created |

## Basic commands

```bash
useradd -g <GID> -G <GID2> <user>   # create a user in primary group GID (and supplementary group GID2).
usermod <options> <user>            # modify a user.
userdel -r <user>                   # delete a user (and its home directory).
groupadd / groupmod / groupdel      # manage groups.

id -a          # show all info about the current user (UID, GUID, groups, etc.) - more precise than "who am i".
sg <group> -c '<command>'   # execute a command as a different group ID (to run scripts or write to a file with group rights).
```

## Password management

```bash
passwd -u <user>                       # unlock a user account.
echo "password" | passwd --stdin <user> # scripted password change.
```

## Account aging

```bash
chage -l <user>   # see the expiration dates.
```

```bash
# list the expiry of every account
for account in $(cut -f1 -d: /etc/passwd); do
  echo "ACCOUNT: $account , EXPIRES: $(chage -l $account | grep 'Account expires' | awk '{print $4, $5, $6}'), CHANGED: $(chage -l $account | grep 'Last password change' | awk '{print $5, $6, $7}')";
done
```

```bash
# change the aging info interactively
chage <user>
```

To unlock an account, set "Last Password Change" to `-1` in `chage` (or use `passwd -u <user>`).