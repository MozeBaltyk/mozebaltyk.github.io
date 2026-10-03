---
date: 2023-08-04T21:00:00+08:00
title: 🧹 Disk Cleanup
nav_weight: 10 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
  - Storage
---

## Find old files

```bash
find . -type f -mtime +150 -exec ls -lrt {} \; | more
find . -maxdepth 1 -name "*.log" -mtime +10 -exec ls -lrt {} \;
find . -mtime +150 -exec rm -f {} \;
```

The `find` loop is cheaper than a shell loop (`for ...`). You can make it even more efficient by batching the `rm` calls:

```bash
find . -type f -print -exec rm -- "{}" +   # note the "+" instead of the usual "\;"
```

## See which directories use the most space

```bash
du -max .                    # list all the FS sub-directories (-x avoids filesystems other than the requested one, "." = search from where you are)
du -sh *                     # show the total without listing the sub-directories (h = human readable)
du -max . | sort -n | tail -30   # the 30 largest files/directories
du -ks * | sort -n           # size in kilobytes of all files and directories, where you are
du -hsc * | sort -h          # from smallest to largest
ls -lrS                      # list files by size (in bytes) - note: ls -l does not give the true value contained in a directory
du -ch /dir/                 # size of the directories contained in /dir/ (with suffix) then the total
```

## Reduce / Truncate a file

```bash
perl -e 'truncate "wanted_file", 100000'
truncate -s 0 /ftpusers/ftp.upload.log
```

## File deleted but space still held by a process

```bash
lsof +aL1                                # "+L1" selects open files that have been "unlinked" (deleted but still open)
lsof -nP | grep '(deleted)'
find /proc/*/fd -type f -links 0 -exec ls -lrt {} \;   # [SunOS]
```

There are two solutions:

1. **reload** or **restart** the process to free the space.
2. If restart or reload is not possible, follow this procedure:

```bash
[root@cacti-server ~]# lsof | grep delete
mysqld  5678  mysql  3w  REG  104,17  14  97730  /var/lib/mysql/mysqld-slow.log (deleted)
```

The highlighted block above is the inode held by the process. You can then find the process (and its `fd`, `cwd`, `exe`, ... descriptors) via `/proc/<PID>`, for example `ls /proc/5678`.