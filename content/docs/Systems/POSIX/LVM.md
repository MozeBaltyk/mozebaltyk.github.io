---
date: 2023-08-28T21:00:00+08:00
title: 📃 LVM
navWeight: 520 # Upper weight gets higher precedence, optional.
series:
  - Unix-Like
  - Disk
categories:
  - Systems
---

## Basic checks 

```bash
# Summary 
pvs
vgs
lvs

# Scanner
pvscan
vgscan
lvscan

# Details info
pvdisplay  [sda]
pvdisplay -m /dev/emcpowerd1 
vgdisplay  [vg_root]
lvdisplay   [/dev/vg_root/lv_usr]

```

## Common Scenario in LVM 

Extend an existing LVM filesystem:
```bash
parted /dev/sda resizepart 3 100%
udevadm settle
pvresize /dev/sda3

# Extend a XFS to a fixe size 
lvextend -L 30G /dev/vg00/var
xfs_growfs /dev/vg00/var  

# Add some space to a ext4 FS
lvextend -L +10G /dev/vg00/var
resize2fs /dev/vg00/var

# Extend to a pourcentage
lvextend -l +100%FREE /dev/vg00/var
```

Create a new LVM filesystem:
```bash
parted /dev/sdb mklabel gpt mkpart primary 1 100% set 1 lvm on
udevadm settle
pvcreate /dev/sdb1
vgcreate vg01 /dev/sdb1
lvcreate -n lv_data -l 100%FREE  vg01

# Create a XFS
mkfs.xfs /dev/vg01/lv_data
mkdir /data
echo "/dev/mapper/vg01-lv_data   /data                  xfs     defaults        0 0" >>  /etc/fstab 
mount -a 

# Create an ext4

```

Remove SWAP:
```bash
swapoff -v /dev/dm-1
lvremove /dev/vg00/swap
vi /etc/fstab
vi /etc/default/grub
grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
grubby --remove-args "rd.lvm.lv=vg00/swap" --update-kernel /boot/vmlinuz-3.10.0-1160.71.1.el7.x86_64
grubby --remove-args "rd.lvm.lv=vg00swap" --update-kernel /boot/vmlinuz-3.10.0-1160.el7.x86_64
grubby --remove-args "rd.lvm.lv=vg00/swap" --update-kernel /boot/vmlinuz-0-rescue-cd2525c8417d4f798a7e6c371121ef34
echo "vm.swappiness = 0" >> /etc/sysctl.conf
sysctl -p
```


## LVM sur une partition VS direct en Raw Disk 
Even if in the past I was using partition MS-DOS disklabel or GPT disklabel for PV, I prefer now to use directly LVM on the main block device. 
There is no reason to use 2 disklabels, unless you have a very specific use case (like disk with boot sector and boot partition).

The advantage of having LVM directly are:
	* simplicity - you do not need to use 2 sets of tools
	* flexibility - you can use pvmove to move the data from one disk volume to another without downtime, you can use snapshot and thin provisioning
	* you do not need to run `partprobe` or `kpartx` to tell the kernel that you created/resized/deleted a volume. 
      And `partprobe` / `kpartx`` could fail if partitions are in use.
    * maybe better performance, compared to using LVM on top of MS-DOS or GPT disklables]