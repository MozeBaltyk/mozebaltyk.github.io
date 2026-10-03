---
date: 2023-08-17T21:00:00+08:00
title: 📜 Logs
nav_weight: 20 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
---

## Where the system logs live

On a Unix machine, the system logs are in `/var/log/messages` (or `/var/adm/messages` on Solaris). This is where you find the errors, with log rotation.

### Default syslog output

| | Linux | Solaris | HP-UX | AIX | BSD |
|---|---|---|---|---|---|
| location | `/var/log/messages`, `/var/log/secure`, `/var/log/boot.log` | `/var/adm/messages` | `/var/adm/syslog/mail.log`, `/var/adm/syslog/syslog.log` | `/tmp` or none | `/var/log/syslog` |

### System accounting (login & process)

{{< table-snippet "systems/unix-like/logs-accounting" "Type,Linux,Solaris,HP-UX,AIX" >}}

### Login errors

| | Linux | Solaris | HP-UX | AIX |
|---|---|---|---|---|
| failed logins | `/var/log/btmp`, `/var/log/messages` | `/var/adm/loginlog`, `/var/adm/sulog` | `/var/adm/sulog` | `/etc/security/failedlogin` |

## Investigate the logs

```bash
# today's logs
grep "$(date '+%b %d')" /var/log/messages

# disk errors (nawk: print the last field of the "Error Block" lines)
nawk '/Error Block/{print $NF}' /var/adm/messages* | sort | uniq

# find the IPs in a log, sort them and remove the duplicates
cat /var/log/maillog | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | uniq
```

## Network investigation

```bash
# ping a list of servers
for ip in $(awk '/192.168.45/ {print $1}' /etc/hosts); do ping -c 1 $ip; done
```

## Investigate on several servers

```bash
for vm in vm{1..27}; do ssh -q $vm "hostname; free; sar -r 3 3"; done
```

## SSH authentication logs

`/var/log/auth.log` — SSH connection logs. Check that there are not too many failed connections (a sign of an intrusion attempt).

```bash
grep "Invalid" /var/log/auth.log
```

## Audit & accounting

* `/var/log/audit/audit.log` — if `auditd` is configured.
* Process accounting (`acct` / `pacct`):

```bash
lastcomm root    # the last commands run by a user (searchable by cmd, user, tty).
```