---
date: 2023-08-13T21:00:00+08:00
title: 🎯 CPU Affinity
nav_weight: 40 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
---

Source : http://www.glennklockwood.com/hpc-howtos/process-affinity.html

## Taskset

```bash
sudo apt-get install util-linux   # or: yum install util-linux
taskset -c 1 script.sh          # run script.sh on CPU number 1  (-c: CPU, -p: PID)
taskset -c 1,2,3 script.sh      # give it several CPUs.
```

## Numactl

```bash
numactl --cpunodebind=0 simulation.x
numactl --cpunodebind=0 --membind=0 simulation.x
numactl -C 0 -N 0 simulation.x
numactl -C +0,1,2,3 simulation.x    # similar to taskset
numactl -H                          # see which memory corresponds to a CPU
```

Note: with `numactl`, unlike `taskset`, you cannot change the CPU affinity of a process on the fly.

## Verification

```bash
# ps -eo pid,tid,class,rtprio,ni,pri,psr,pcpu,stat,wchan:14,comm
  PID   TID CLS RTPRIO  NI PRI PSR %CPU STAT WCHAN          COMMAND
    1     1 TS       -   0  19   4  0.0 Ss   -              init
    2     2 TS       -   0  19   3  0.0 S    kthreadd       kthreadd
    3     3 TS       -   0  19   0  0.0 S    run_ksoftirqd  ksoftirqd/0
    6     6 FF      99   - 139   0  0.0 S    cpu_stopper_th migration/0
    7     7 FF      99   - 139   0  0.0 S    watchdog       watchdog/0
```

```bash
# taskset -c -p 4806
pid 4806's current affinity list: 0-3
```