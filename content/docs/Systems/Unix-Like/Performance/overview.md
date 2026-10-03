---
date: 2023-08-05T21:00:00+08:00
title: 📈 Performance Monitoring & Tuning
nav_weight: 10 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
---

How to approach performance monitoring and tuning in Linux, and the various subsystems (and performance metrics) that need to be monitored.

On a very high level, the following four subsystems need to be monitored:

* CPU
* Memory
* I/O
* Network

## 1. CPU

Four critical performance metrics for the CPU: **context switch**, **run queue**, **CPU utilization**, and **load average**.

### Context Switch

* When the CPU switches from one process (or thread) to another, it is called a context switch.
* When a process switch happens, the kernel stores the current state of the CPU (of a process or thread) in memory.
* The kernel also retrieves the previously stored state (of a process or thread) from memory and puts it in the CPU.
* Context switching is essential for multitasking of the CPU.
* However, a higher level of context switching can cause performance issues.

### Run Queue

* The run queue indicates the total number of active processes in the current queue for the CPU.
* When the CPU is ready to execute a process, it picks it up from the run queue based on the priority of the process.
* Note that processes that are in a sleep state, or I/O wait state, are not in the run queue.
* A higher number of processes in the run queue can therefore cause performance issues.

### CPU Utilization

* Indicates how much of the CPU is currently being used.
* 100% CPU utilization means the system is fully loaded.

### Load Average

* Indicates the average CPU load over a specific time period.
* On Linux, load average is displayed for the last 1 minute, 5 minutes, and 15 minutes. This helps to see whether the overall load on the system is going up or down. For example, a load average of `0.75 1.70 2.10` indicates that the load is coming down (0.75 = last 1 minute, 1.70 = last 5 minutes, 2.10 = last 15 minutes).
* Note that this load average is calculated by combining both the total number of processes in the queue, and the total number of processes in the uninterruptible task status.

## 2. Network

* A good understanding of TCP/IP concepts is helpful when analyzing any network issue.
* For network interfaces, monitor the total number of packets (and bytes) received/sent through the interface, the number of packets dropped, etc.

## 3. I/O

* I/O wait is the amount of time the CPU is waiting for I/O. Consistent high I/O wait on the system indicates a problem in the disk subsystem.
* Monitor **reads/second** and **writes/second**. These are measured in blocks, i.e. the number of blocks read/written per second. They are also referred to as **bi** and **bo** (block in and block out).
* **tps** indicates total transactions per second, which is the sum of **rtps** (read transactions per second) and **wtps** (write transactions per second).

## 4. Memory

* RAM is the physical memory. If you have 4 GB of RAM installed, you have 4 GB of physical memory.
* Virtual memory = swap space available on disk + physical memory.
* The virtual memory contains both user space and kernel space.
* Using a 32-bit or a 64-bit system makes a big difference in determining how much memory a process can use:
  * On a 32-bit system a process can only access a maximum of 4 GB of virtual memory.
  * On a 64-bit system there is no such limitation.
* Unused RAM is used by the kernel as filesystem cache.
* Linux swaps when it needs more memory than the physical memory. When it swaps, it writes the least-used memory pages from the physical memory to the swap space on the disk.
* Lots of swapping can cause performance issues: the disk is much slower than the physical memory, and it takes time to swap the memory pages from RAM to disk.

## The subsystems are interrelated

All four subsystems are interrelated. Just because you see a high reads/second, writes/second, or I/O wait, it does not mean the issue is with the I/O subsystem. It also depends on what the application is doing. In most cases, the performance issue is caused by the application running on the Linux system.

Remember the **80/20 rule**: 80% of the performance improvement comes from tuning the application, and the remaining 20% comes from tuning the infrastructure components.

## Tools

There are various tools available to monitor Linux system performance, for example: `top`, `free`, `ps`, `iostat`, `vmstat`, `mpstat`, `sar`, `tcpdump`, `netstat`, `iozone`, etc.

## 4-step approach to identify and solve a performance issue

1. **Understand (and reproduce) the problem** — Half of the problem is solved when you clearly understand what the problem is. Before trying to solve the performance issue, first work on clearly defining it. The more time you spend understanding and defining the problem, the more details you will have to look for the answers in the right place. If possible, reproduce the problem, or at least simulate a situation that closely resembles it (this will later help validate the solution).
2. **Monitor and collect data** — After defining the problem, monitor the system and collect as much data as possible on the various subsystems. Based on this data, list the potential issues.
3. **Eliminate and narrow down issues** — Go through each potential issue and eliminate the non-issues. Narrow it down to whether it is an application issue or an infrastructure issue, then to a specific component. For example, for an I/O subsystem issue, narrow it down to a specific partition, RAID group, LUN, or disk. Keep drilling down until you identify the root cause.
4. **One change at a time** — Don't make multiple changes at once, or you won't know which one fixed the original issue (and may introduce new ones). Make one change at a time and see whether it fixes the original problem.