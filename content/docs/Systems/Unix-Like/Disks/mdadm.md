---
date: 2023-08-29T21:00:00+08:00
title: 🌱 MDadm
navWeight: 510 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Systems
  - Unix-Like
  - Disks
  - Storage
---


## The Basics

mdadm (multiple devices admin) is software solution to manage RAID.    
   
It allow: 
  - create, manage, monitor your disks in an RAID array.
  - you can the full disks (`/dev/sdb, /dev/sdc`) or (`/dev/sdb1, /dev/sdc1`)
  - replace or complete `raidtools`
	
## Checks 

* Basic checks 
```bash
# View real-time information about your md devices
cat /proc/mdstat 

# Monitor for failed disks (indicated by "(F)" next to the disk)
watch cat /proc/mdstat
```

* Checks RAID
```bash
# Display details about the RAID array (replace /dev/md0 with your array)
mdadm --detail /dev/md0 

# Examine RAID disks for information (not volume) similar to --detail
mdadm --examine /dev/sd*
```

## Settings

The conf file `/etc/mdadm.conf` does not exist by default and need to be created once you finish your install. 
This file is required for the autobuild at boot. 

```bash
# mdadm --detail -scan 
ARRAY /dev/md0 level=linear num-devices=2 metadata=1.2 name=localhost.localdomain:0 UUID=a50ac9f2:62646d92:725255bd:7f9d30e3 devices=/dev/sdb,/dev/sdc 
	
# As seen in the output above, I have a linear array md0 with 2 devices /dev/sdb and /dev/sdc.
mdadm --verbose --detail -scan > /etc/mdadm.conf 
mdadm --examine -scan > /etc/mdadm.conf
```

## Corrective Actions 

* Put back the config 
```bash
mdadm -D --scan
mdadm -D /dev/md3 --scan
mdadm -D /dev/md3 --scan >> /etc/mdadm.conf
```

* Remove and Add a disk without downtime (almost) 
```bash
mdadm -D /dev/md124
mdadm --manage --remove /dev/md124 /dev/san/BETZ9C50D4C
mdadm --manage --add /dev/md124 /dev/san/BETZ9C50D4C

# one command-line
mdadm /dev/md5 --remove /dev/dm-64 --add /dev/dm-64

ls -l /dev/dm-64 
mdadm /dev/md5  --add /dev/dm-64 
mdadm --detail /dev/md5

mdadm --assemble --force /dev/md/pvdata_2 /dev/sd[n-y]
```
		
## Create and manage RAID array

* Linear Mode
```bash
# Longue Version
mdadm --create --verbose /dev/md0 --level=linear --raid-devices=2 /dev/sdb /dev/sdc

# Short version
mdadm --Cv /dev/md0 --l linear -n2 /dev/sdb /dev/sdc
```
		
* RAID 0
```bash
mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/sdb /dev/sdc
```

* RAID 1
```bash
mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc --spare-devices=/dev/sdd
```

* RAID 5
```bash
# with 3 devices and a spare
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd --spare-devices=/dev/sde  

# with 6 devices
mdadm --create --verbose /dev/md/pvdata_1 --level=5 --raid-devices=6 --assume-clean /dev/sd[c-h]
```
		
* Attach your fs to an Array
```bash
mkfs.ext4 /dev/md0
mkdir /data01
mount /dev/md0 /data01
# Add it to /etc/fstab
```

* Delete a Array
```bash		
mdadm --stop /dev/md0
mdadm --remove /dev/md0
```

* Relaunch a Array 
```bash
mdadm --stop /dev/md0
mdadm --assemble /dev/md0
```

> The `assemble` command relies on the `/etc/mdadm.conf` file for array configuration. Ensure you've saved your configuration in `mdadm.conf` before stopping the array to prevent issues during reassembly.
		
* Add disk to an Array 
```bash
mdadm --add /dev/md0 /dev/sdd
```
		
* Remove a disks from an Array - first fail a device (-f) from an array and then remove (-r) it.
```bash
mdadm --manage /dev/md0 -f /dev/sdd
mdadm --manage /dev/md0 -r /dev/sdd
```
		
* Change a disk on a RAID mirroring: 

```bash
# First data need to be writen
sync; sync; sync
# Put in fail 
mdadm --manage /dev/md0 --fail /dev/sdb1
# Remove disk
mdadm --manage /dev/md0 --remove /dev/sdb1
# Copy partition table
sfdisk -d /dev/sda | sfdisk /dev/sdb
# Recreate mirror
mdadm --manage /dev/md0 --add /dev/sdb1
# Test and check the rebuild 
/sbin/mdadm --detail /dev/md0 
cat /proc/mdstat 
```
