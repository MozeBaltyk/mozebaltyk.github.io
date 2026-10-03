---
date: 2023-08-16T21:00:00+08:00
title: ⏲️ Cron & Anacron
nav_weight: 60 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
---

## Configurations

* `/etc/crontab` : the daemon's configuration file, defining the default behaviour of `crond` (SHELL, MAILTO, etc.).
* `/etc/cron.d/...` : system crontab (used by admins).
* `/var/spool/cron/root` : crontab per user.

{{< bs/alert warning >}}
{{< markdownify >}}
"Day of month" and "Day of week" are combined with a logical **OR**, so if both are set, the job runs on that day of the month *and* on that day of the week.
{{< /markdownify >}}
{{< /bs/alert >}}

```bash
MAILTO="admin@example.com"
* * * * *  root  /usr/local/sbin/mycommand.sh > /dev/null 2>&1
```

## Anacron

* `/etc/anacrontab` : file that runs, via the `run-parts` command, `/etc/cron.daily`, `/etc/cron.weekly`, `/etc/cron.monthly`.
* `/etc/cron.d/0hourly` : exception, runs `/etc/cron.hourly` via `run-parts`, checking the last run of the task in `/var/spool/anacron/...`.

## Special cases

Exactly the last day of each month:

```bash
* 5 * * * [ $(date --date=tomorrow +%d) -eq 1 ] && /bin/my/script/backup/example
```

Every Monday, but only once every two weeks:

```bash
30 1 * * 1 [ $(expr $(date +%W) % 2) -eq 1 ] && /home/oracle/dba/backup/bin/oracle_rman_backup.sh FULL > /dev/null 2>&1
```

## Log

```bash
/var/log/cron
```