---
date: 2023-08-29T21:00:00+08:00
title: 🩺 multipath
navWeight: 510 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Systems
  - Unix-Like
  - Disks
  - HA
---


## Install and Set Multipath

```bash
yum install device-mapper-multipath
```

* Check settings in `vim /etc/multipath.conf`:
```json
defaults {
user_friendly_names yes
path_grouping_policy multibus
}
```

* add disk in blacklisted and a block 
```json
multipaths {
        multipath {
                wwid "36000d310004142000000000000000f23"
                alias oralog1
        }
```

* Special config for some providers. For example, recommended settings for all Clariion/VNX/Unity class arrays that support ALUA:
```json
    devices {
      device {
        vendor "DGC"
        product ".*"
        product_blacklist "LUNZ"
        :
        path_checker emc_clariion   ### Rev 47 alua
        hardware_handler "1 alua"   ### modified for alua
        prio alua                   ### modified for alua
        :
      }
    }
```

* Checks config with: `multipathd show config |more` 

* Once `multipath.conf` configured, perform following steps to start multipathd:
```bash
modprobe dm-multipath
systemctl reload multipathd
multipath -d                   # Dry run
multipath -v2                  # Commits configuration
```

* Get WWID - needed for the FS or UDEV config: 
```bash
for i in {b..i}; do /lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/sd${i}; done | sort | uniq

for i in {{a..z},{a..z}{a..z}}; do /lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/sd${i}; done | sort | uniq

for i in {{a..z},{a..z}{a..z}}; do WWID=$(/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/sd${i}); echo "/dev/sd${i} = $WWID"; done | sort -t"=" -k2

for i in {{a..z},{a..z}{a..z}}; do /lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/sd${i}; done | sort | uniq -c

udevadm info --query=all --name=/dev/mapper/oradataemc1 |  grep -i "DM_UUID"
```

## ALUA 
⚠️ for DGC (CLARiiON) or VNX storage arrays - special config due to the fact that "path checker" is optimized for Passive Not Ready (PNR) failover mode 1 and not for ALUA failover mode 4.

* To check if ALUA is active

```bash
# Install 
yum install sg3_utils

# Case where not supported: 
sg_rtpg /dev/sdf
Report Target Port Groups command not supported

#Cas supported: 
sg_rtpg -vvd /dev/sdf
open /dev/sdf with flags=0x802
    report target port groups cdb: a3 0a 00 00 00 00 00 00 04 00 00 00
    report target port group: pass-through requested 1024 bytes but got 52 bytes
Report list length = 52
Report target port groups:
  target port group id : 0x1 , Pref=0
    target port group asymmetric access state : 0x01 (active/non optimized)
    T_SUP : 0, O_SUP : 0, LBD_SUP : 0, U_SUP : 1, S_SUP : 0, AN_SUP : 1, AO_SUP : 1
    status code : 0x01 (target port asym. state changed by SET TARGET PORT GROUPS command)
    vendor unique status : 0x00
    target port count : 04
    Relative target port ids:
      0x01
      0x02
      0x03
      0x04
  target port group id : 0x2 , Pref=1
    target port group asymmetric access state : 0x00 (active/optimized)
    T_SUP : 0, O_SUP : 0, LBD_SUP : 0, U_SUP : 1, S_SUP : 0, AN_SUP : 1, AO_SUP : 1
    status code : 0x01 (target port asym. state changed by SET TARGET PORT GROUPS command)
    vendor unique status : 0x00
    target port count : 04
    Relative target port ids:
      0x05
      0x06
      0x07
      0x08
```

## Basic Checks 

* `multipath -ll`
```bash
   mpath2 (360060e80057110000000711000005405) dm-8 HP,OPEN-V
   [size=408G][features=1 queue_if_no_path][hwhandler=0][rw]
   \_ round-robin 0 [prio=2][active]
    \_ 2:0:1:0 sdc 8:32  [active][ready]
    \_ 3:0:2:0 sdn 8:208 [active][ready]

Other type of Output :
WIND9CB0D67 dm-20 HITACHI ,OPEN-V          
size=55G features='1 queue_if_no_path' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  |- 3:0:1:6  sdal               66:80      active ready running
  `- 2:0:1:6  sdj                8:144      active ready running
```

* `multipathd show paths`
```bash
hcil    dev dev_t pri dm_st  chk_st dev_st  next_check
1:0:0:1 sdf 8:80  10  active ready  running .......... 3/40
1:0:0:2 sdm 8:192 50  active ready  running .......... 3/40
1:0:0:3 sdo 8:224 50  active ready  running .......... 3/40
1:0:0:4 sdt 65:48 10  active ready  running .......... 3/40
2:0:0:1 sdg 8:96  50  active ready  running .......... 3/40
2:0:0:2 sdk 8:160 10  active ready  running X......... 4/40
```

* `dmsetup info WIND9C50D4C`
```bash
Name:              WIND9C50D4C
State:             ACTIVE
Read Ahead:        8192
Tables present:    LIVE
Open count:        1
Event number:      0
Major, minor:      253, 10
Number of targets: 1
UUID: mpath-WIND9C50D4C
```

* `dmsetup info -c`
```bash
Name                           Maj Min Stat Open Targ Event  UUID                                                                
vgdata-local_0rddb_prod        253  76 L--w    1    3      0 LVM-L4zKBVvimtzjKK80DUxiTGZXVYjEufrH6DrZllZR2tw7vtH2D9NJRbC3Jta8QuRO
vgdata-local_0lucas_prod       253  74 L--w    1    1      0 LVM-L4zKBVvimtzjKK80DUxiTGZXVYjEufrHF8nplAxZfZBkVUP4ndcJvCrNP5UOAfIA
vgdata-prod_0tris_prod         253  11 L--w    1    3      0 LVM-L4zKBVvimtzjKK80DUxiTGZXVYjEufrHISKMHLqUw4FnG4iKyFiMYsDVmj2i63jF
vgdata-local_0pestic_test      253  44 L--w    1    1      0 LVM-L4zKBVvimtzjKK80DUxiTGZXVYjEufrHHESnLA5qupQVnfmZw2UiloFM5CtrDecO
```

* `dmsetup ls`
```bash
ol-var  (249:4)
orafraemc1      (249:7)
ol-lv_swap      (249:6)
ol-home (249:3)
ol-opt  (249:1)
oralogemc1      (249:8)
ol-lv_oracle    (249:5)
ol-root (249:0)
oradataemc2     (249:9)
oradataemc1     (249:10)
ol-tmp  (249:2)
```

* `dmsetup deps /dev/syno/syno`
```bash
1 dependencies  : (8, 33)
```

## Delete a LUN from multipath

```bash
# Dynamic delete (non-permanent change, so it come back after reboot)
multipath -f "3600508b4000971cd0001000022fa0000"

# Static delete
vi /etc/multipath.conf

# Then reload
systemctl reload multipathd

# Restart to recover a multipath config 
multipath -r
```
