---
date: 2023-08-12T21:00:00+08:00
title: 🐛 Tracing (strace / ltrace / gstack)
nav_weight: 30 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
---

## Strace - trace system calls

```bash
strace -tt -p 24503

strace -o strace01.out -e open -f bash --login -i   # see the files opened during a bash connection.
    # -o redirects the output / -e filters the system calls / -f follows forks (child processes)

strace -f <binary_script> 2> trace.log :  stdout -> the binary command result, stderr -> the binary's system calls.
```

## Ltrace - trace library calls

`ltrace` traces shared-library calls (like `strace`, but at the library-call level).

## gstack (SUSE) - investigate a process

```bash
gstack `ps -ef | grep nimserver_agent | grep -v grep | awk -F" " '{print $2}'` > /opt/oss/server/var/logs/nimserver_agent1.stack
```