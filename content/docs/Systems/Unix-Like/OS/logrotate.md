---
date: 2023-08-16T21:00:00+08:00
title: 📜 Logrotate
nav_weight: 80 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
---

```bash
logrotate -d /etc/logrotate.d/app   # test a new configuration.
reading config info for /data/log/app
Handling 1 logs
rotating pattern: /data/log/app  after 1 days (10 rotations)
empty log files are rotated, old logs are removed
```

## Options

```
Usage: logrotate [OPTION...] <configfile>
  -d, --debug               Don't do anything, just test (implies -v)
  -f, --force               Force file rotation
  -m, --mail=command        Command to send mail (instead of `/bin/mail')
  -s, --state=statefile     Path of state file
  -v, --verbose             Display messages during rotation
```