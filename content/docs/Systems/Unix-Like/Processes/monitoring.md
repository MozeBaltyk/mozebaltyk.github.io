---
date: 2023-08-11T21:00:00+08:00
title: 📊 Process Monitoring (pidstat)
nav_weight: 20 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
---

`pidstat` reports the CPU, memory, I/O and context-switch activity of processes.

## Report the process context-switching activity

```bash
# pidstat -w -p 3446 2 5
Linux 3.10.0-123.13.2.el7.x86_64 (localhost.localdomain) 12/26/2014
_x86_64_ (1 CPU)
07:23:38 AM UID PID cswch/s nvcswch/s Command
07:23:40 AM 0 3446 0.50 0.00 sshd
07:23:42 AM 0 3446 0.50 0.00 sshd
07:23:44 AM 0 3446 0.50 0.00 sshd
07:23:46 AM 0 3446 0.50 0.00 sshd
07:23:48 AM 0 3446 0.50 0.00 sshd
Average: 0 3446 0.50 0.00 sshd
```

* `cswch/s` : number of voluntary context switches the task made per second. (A voluntary context switch occurs when a task blocks because it requires a resource that is unavailable.)
* `nvcswch/s` : number of non-voluntary context switches the task made per second. (An involuntary context switch takes place when a task executes for the duration of its time slice and is then forced to relinquish the processor.)

## Page faults and memory

```bash
pidstat -r -p <PID> 3600 72    # every hour, 72 times - practical for long-term monitoring.

pidstat -r -p <PID> 50 12
07:26:44 PM       PID   minflt/s  majflt/s     VSZ    RSS   %MEM  Command
07:27:34 PM     13775      1.64      0.00 34957320 18183312  55.30  java
```

* `minflt/s` : number of minor faults the task has made per second — those which did not require loading a memory page from disk.
* `majflt/s` : number of major faults the task has made per second — those which required loading a memory page from disk.
* `VSZ` : Virtual Size — the virtual memory usage of the entire task in kilobytes.
* `RSS` : Resident Set Size — the non-swapped physical memory used by the task in kilobytes.

## Disk I/O

```bash
pidstat -d -p <PID> 50 12
```

`pidstat -d` reports I/O statistics (kernels 2.6.20 and later only). The following values are displayed:

* `kB_rd/s` : number of kilobytes the task has caused to be read from disk per second.
* `kB_wr/s` : number of kilobytes the task has caused, or shall cause, to be written to disk per second.
* `kB_ccwr/s` : number of kilobytes whose writing to disk has been cancelled by the task. This may occur when the task truncates some dirty pagecache; in that case, some I/O which another task was accounted for will not happen.

## CPU (default mode)

`pidstat` reports the CPU usage by default.