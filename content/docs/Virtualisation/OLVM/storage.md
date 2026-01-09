---
date: 2023-08-01T21:00:00+08:00
title: 📐 Storage
navWeight: 60 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Virtualisation
  - Oracle
  - Storage
  - KVM
---

## General concern 

* If you want to move VMs to an another Storage Domain, you need to copy the template from it as well! 

* Remove a disk:

```bash
# IF RHV does not use anymore disk those should appear empty in lsblk: 
lsblk -a
sdf                                                                                     8:80   0     4T  0 disk
└─36001405893b456536be4d67a7f6716e3                                                   253:38   0     4T  0 mpath
sdg                                                                                     8:96   0     4T  0 disk
└─36001405893b456536be4d67a7f6716e3                                                   253:38   0     4T  0 mpath
sdh                                                                                     8:112  0     4T  0 disk
└─36001405893b456536be4d67a7f6716e3                                                   253:38   0     4T  0 mpath
sdi                                                                                     8:128  0         0 disk
└─360014052ab23b1cee074fe38059d7c94                                                   253:39   0   100G  0 mpath
sdj                                                                                     8:144  0         0 disk
└─360014052ab23b1cee074fe38059d7c94                                                   253:39   0   100G  0 mpath
sdk                                                                                     8:160  0         0 disk
└─360014052ab23b1cee074fe38059d7c94                                                   253:39   0   100G  0 mpath

# find all disks from LUN ID
LUN_ID="360014054ce7e566a01d44c1a4758b092"
list_disk=$(dmsetup deps -o devname ${LUN_ID}| cut -f 2 |cut -c 3- |tr -d "()" | tr " " "\n")
echo ${list_disk}

# Remove from multipath 
multipath -f "${LUN_ID}"

# remove disk 
for i in ${list_disk}; do echo ${i}; blockdev --flushbufs /dev/${i}; echo 1 > /sys/block/${i}/device/delete; done

# You can which disk link with which LUN on CEPH side 
ls -l /dev/disk/by-*
```

### NFS for OLVM/oVirt

Since oVirt need a shared stockage, we can create a local NFS to bypass this point if no Storage bay. 

```sh
parted /dev/sda
pvcreate /dev/sda2
vgcreate rhvh /dev/sda2
lvcreate -L 100G rhvh -n data
mkfs.ext4 /dev/mapper/rhvh-data
echo "/dev/mapper/rhvh-data /data ext4 defaults,discard 1 2" >> /etc/fstab

chown 36:36 /data
chmod 0755 /data
dnf install nfs-utils -y
systemctl enable --now nfs-server
systemctl enable --now rpcbind
echo "/data *(rw)" >> /etc/exports
firewall-cmd --add-service=nfs –permanent
firewall-cmd –reload

exportfs -rav
exportfs 
```

### ISCSI 

* ISCSI need to be at discovered before install (ref to iscsi doc)

* Adding a disk:

https://access.redhat.com/documentation/en-us/red_hat_virtualization/4.4/html-single/administration_guide/index#Adding_iSCSI_Storage_storage_admin

* config for CEPH iscsi volume with multipathing:

```bash
# Look for LIO
multipathd show config |more

# Replace TCMU with RBD
sed -i 's/TCMU device/RBD/g' /etc/multipath.conf

# Check config
cat /etc/multipath.conf | grep -v \# |sed '/^$/d'
defaults {
polling_interval 5
no_path_retry 16
user_friendly_names no
flush_on_last_del yes
fast_io_fail_tmo 5
dev_loss_tmo 30
max_fds 4096
}
blacklist {
protocol "(scsi:adt|scsi:sbp)"
}
overrides {
no_path_retry 16
}
devices {
device {
vendor "LIO-ORG"
product "RBD"
hardware_handler "1 alua"
path_grouping_policy "failover"
path_selector "queue-length 0"
failback 60
path_checker tur
prio alua
prio_args exclusive_pref_bit
fast_io_fail_tmo 25
no_path_retry queue
}
}

# Restart
systemctl restart iscsi
systemctl restart multipathd
systemctl status multipathd -l
systemctl status iscsi -l
iscsiadm -m discovery -t st -p 172.16.12.50:3260
iscsiadm -m node -T iqn.2003-01.com.redhat.iscsi-gw:ceph-igw -l
iscsiadm -m session
iscsiadm -m session -P 3
```



