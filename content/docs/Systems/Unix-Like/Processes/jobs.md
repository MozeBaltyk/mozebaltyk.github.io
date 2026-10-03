---
date: 2023-08-14T21:00:00+08:00
title: ⏰ Jobs & Background
nav_weight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
---

## Schedule a task (at / batch)

```bash
at      :  schedule a task to run at a later time (/!\ it executes what you give it on stdin).
           ex :  at 18:22 < "date; ps -ef | wc -l"
           or : at now + 5 hours  then type your commands then ctrl + d
at -q a 16:05 tomorrow   :  -q defines the queue (a-z), i.e. the priority.
at -c  <job_number>      :  see the context and the commands of the task.
atq      :  list the pending jobs (= at -l).
atrm     :  delete a job.

batch   :  schedule a task when the load average is below a threshold.
```

## Run jobs in the background

```bash
jobs -l   : list the running tasks.
```

```bash
# Nohup in series
for i in {1..6}; do echo "nohup sh -c \"shred -vfz -n 3 /dev/cciss/c0d${i} > nohup${i}.out 2>&1 \" &" ; done | bash
```

Three points to remember:

* Serial `nohup`s cannot all write at once to the same default log (`nohup.out`): `> nohup${i}.out 2>&1`.
* `nohup` does not support a `for` loop, so you have to generate the command with `echo` and redirect it to `bash`.
* `nohup` for a long command: `nohup sh -c "command with arguments"`.

```bash
&          :  putting & at the end of a command lets you launch another without waiting for the first to finish.
             ex : cp video.avi /users/user/desktop/copy-video.avi &.
nohup      :  launches the program and keeps it running even once the console is closed (outputs 1&2 are redirected to nohup.out).
ctrl + z   :  pause the current process.
bg         :  move the paused process to the background.
fg         :  resume a process in the foreground (if several run at once, fg %n).
sleep      :  pause between the execution of two commands.
             Example :  touch gt.txt && sleep 10 && rm gt.txt.
             The pause is in seconds by default, but you can add a unit after the number: m, h, or d for minutes, hours, days.
```

## Repeat a command (watch)

```bash
watch  <cmd>  :  repeats a command every 2 sec. (-n X, to choose the interval)
watch -d      :  repeats a command and only shows the difference between two results.
watch -d 'ls -lrt'             :  watch whether files are created.
watch -d 'ls -lrt | fgrep joe' :  watch whether files are created by the user joe.
```