---
date: 2023-08-16T21:00:00+08:00
title: 🕐 NTP & Time Synchronisation
nav_weight: 90 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
  - Networking
---

## Client verification (ntpd / chrony)

```bash
ntpstat    # see which NTP server we synchronise with, and whether the sync is good.
```

```bash
synchronised to NTP server (192.168.1.12) at stratum 4
   time correct to within 68 ms
   polling server every 1024 s
```

```bash
ntpq -p     # see the state of the peers.
ntpq -c peers
```

```
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
+192.168.1.11     192.168.2.4    4 u  259 1024  373    0.731   -0.980   0.557
*192.168.1.12     192.168.3.21   3 u  385 1024  377    0.773    0.146   0.365
 192.168.4.255    .BCST.         16 u    -   64    0    0.000    0.000   0.000
```

* The server preceded by an asterisk (`*`) is the one being used.
* Those preceded by a `-` are currently discarded by the server-selection algorithm.
* Those whose name is preceded by a `+` are possible synchronisation candidates.
* A server preceded by a space is either unreachable or too distant.

### Column meaning

* `remote` — the server name.
* `refid` — the parent server's identifier.
* `st` — the server's stratum.
* `t` — the server type.
* `when` — seconds elapsed since the last contact.
* `poll` — seconds between each contact.
* `reach` — bitmask of successful contacts (octal): the server considers itself synchronised when `reach` reaches `177`; a quality, stable connection shows `377`.
* `delay` — estimated round-trip time (ms) of the UDP packet.
* `offset` — estimated difference between the peer's clock and the internal clock.
* `jitter` — dispersion of the reference values obtained from this peer.

## Restart the NTP daemon

```bash
service ntpd restart      # or: systemctl restart ntpd
```

## Configuration & logs

```bash
cat /etc/ntp.conf    # "server example.com" + restart ntpd + enable
/var/log/ntpstats
```

## ntpdate (legacy)

Old service that synchronises NTP at boot (install the package first).

```bash
ntpdate 192.168.1.12          # + enable the ntpdate service
ntpdate -ubd 192.168.1.12     # -b sync immediately, -u unprivileged port, -d debug mode to see all the steps
/etc/ntp/step-tickers
```

{{< bs/alert warning >}}
`ntpdate` is deprecated — prefer `chronyd` or `systemd-timesyncd`.
{{< /bs/alert >}}

## NTP server side

```bash
ntpdc -c monlist    # normally used on an NTP server to list its clients.
```

## Know the stratum level of an NTP server

```bash
ntptrace
ntp-server: stratum 3, offset 0.000791, synch distance 0.069005
192.168.5.33: stratum 2, offset -0.000125, synch distance 0.016285
```

## timedatectl / systemd-timesyncd (RHEL 7+, Ubuntu 15+)

```bash
timedatectl                       # = ntpdate + ntp combined.
timedatectl status
timedatectl set-ntp true

timedatectl list-timezones | grep Paris
sudo timedatectl set-timezone Europe/Paris

/etc/systemd/timesyncd.conf       # timesyncd = ntpd
```

## chrony

```bash
chronyc sources -v
```

```
[root@server ~]# chronyc tracking
Reference ID    : 00000000 ()
Stratum         : 0
Ref time (UTC)  : Thu Jan 01 00:00:00 1970
System time     : 0.000000000 seconds fast of NTP time
Last offset     : +0.000000000 seconds
...
Leap status     : Not synchronised
```

```bash
chronyc sourcestats
210 Number of sources = 2
Name/IP Address            NP  NR  Span  Frequency  Freq Skew  Offset  Std Dev
==============================================================================
ntp1.example.com            0   0     0     +0.000   2000.000     +0ns  4000ms
ntp2.example.com            0   0     0     +0.000   2000.000     +0ns  4000ms
```

```bash
systemctl restart chronyd
watch chronyc tracking
```