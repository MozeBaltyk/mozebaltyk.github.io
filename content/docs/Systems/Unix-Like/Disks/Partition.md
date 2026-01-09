---
date: 2023-08-30T21:00:00+08:00
title: 🗿 Partition
navWeight: 500 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Systems
  - Unix-Like
  - Disks
  - Partitions
---

	
## Checks your disks

```bash
# check partion 
parted -l /dev/sda
fdisk -l 

# check partition - visible before the mkfs
ls /sys/sda/sda*    
ls /dev/sd* 

# give partition after the mkfs or pvcreate
blkid
blkid -o list

# summary about the disks, partitions, FS and LVM 
lsblk   
lsblk -f
```

## Create Partition 1 on disk sdb 

in script mode
```bash
# with fdisk 
printf "n\np\n1\n\n\nt\n8e\nw\n" | sudo fdisk "/dev/sdb"

# with parted
sudo parted /dev/sdb mklabel gpt mkpart primary 1 100% set 1 lvm on
``` 

Gparted  :  interface graphique  (ce base sur parted un utilitaire GNU - Table GPT) 


## Rescan 

Inform OS that the partitionning table changed (so you do not need to reboot)

```bash
# [RHEL6]   
partx -a /dev/sda

# [RHEL6/7] 
partprobe

# [RHEL7]  
partx -u /dev/sdq
kpartx -u /dev/sdq

# [RHEL8]   
udevadm settle

# [Manual] 
for x in /sys/class/scsi_disk/*; do echo '1' > $x/device/rescan; done
for BUS in /sys/class/scsi_host/host*/scan; do    echo "- - -" >  ${BUS}; done

# same as above with sudo 
sudo sh -c 'for x in /sys/class/scsi_disk/*; do echo "1" > $x/device/rescan; done'
sudo sh -c 'for BUS in /sys/class/scsi_host/host*/scan; do  echo "- - -" >  ${BUS} ; done '
```

## ⚠️ Cleanup and erase disks ⚠️

Here you wipe staff, do not expect to get it back ! 

```bash 
wipe -a /dev/sda3
wipefs -a  /dev/sd[c-z] 

# in RHEL 5
shred -n 5 -vz /dev/sdb 

# check; the following should return nothing 
wipefs /dev/sd[c-z]  

# old school way
dd if=/dev/urandom of=/dev/sdX bs=4k
dd if=/dev/zero of=/dev/sdp1 bs=512 count=10 

# When you like to do several disks at once... 
umount /dev/cciss/c0d{1..6}p1
for i in {1..6}; do parted -s /dev/cciss/c0d${i} rm 1 ; done
for i in {1..6}; do echo "nohup sh -c \"shred -vfz -n 3 /dev/cciss/c0d${i} > nohup${i}.out 2>&1 \" &" ; done | bash 
```

Dban Autonuke 💣 – this also work when it comes to erase all disks...  
	https://sourceforge.net/projects/dban/files/dban/
	dban-1.0.7  => Previous Version for HP ilo2 with Array cciss 
	dban-2.3.0  => Recent Version 

## Partitioning

Hard disks: 
- `sdx` = SCSI/SATA disks 
- `hdx` = IDE/parallel-ATA disks
- `md0` = mdadm disks which is a RAID software
- `vda` = virtual disks

> in BSD/Solaris naming convention is different `cXtXdX` = (c = controler, t = target, d = device)

Patitions labels are just for informations purpose:
	5 => extended partitions 
	7 => NTFS Windows 
	82 => SWAP
	83 => standard partition (needed for /boot)
	8e => LVM partition 

> Remember that **primary** partitions are limited to 4. so if you need more partition one of the **primary** should be define as **extended**.    
> But in BSD and Solaris, the logic is different. Parition are considered as **slice** and you can have from 0 to 7 **slices** (so 8 **slices** possible), 
> which explain why naming convention is different. 
