---
date: 2023-08-16T21:00:00+08:00
title: 📦 Chroot Jail
nav_weight: 70 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
---

Change the root directory of a command or a process, and its children.

{{< bs/alert warning >}}
In no case should `chroot` be relied upon as a security boundary — a process running as root can escape the jail.
{{< /bs/alert >}}

## Example: creating a chroot

```bash
# create the "jail" directory
J=$HOME/jail
mkdir -p $J
mkdir -p $J/{bin,lib64,lib}
cd $J

# copy the binaries and their libraries into the jail
cp -v /bin/{bash,ls} $J/bin

list="$(ldd /bin/bash | egrep -o '/lib.*\.[0-9]')"
for i in $list; do cp -v "$i" "${J}${i}"; done

list="$(ldd /bin/ls | egrep -o '/lib.*\.[0-9]')"
for i in $list; do cp -v "$i" "${J}${i}"; done

# enter the jail
sudo chroot $J /bin/bash
```