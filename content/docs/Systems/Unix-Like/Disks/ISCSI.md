---
date: 2023-08-29T21:00:00+08:00
title: 🧱 ISCSI
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


### Install

```bash
yum install iscsi-initiator-utils

#Checks
iscsiadm -m session -P 0  #   get the target name
iscsiadm -m session -P 3 | grep "Target: iqn\|Attached scsi disk\|Current Portal"

# Discover and mount ISCSI disk 
iscsiadm -m discovery -t st -p 192.168.40.112
iscsiadm --mode discovery --type sendtargets --portal 192.168.40.112

# Login
iscsiadm -m node -T iqn.1992-04.com.emc:cx.ckm00192201413.b0 -l
iscsiadm -m node -T iqn.1992-04.com.emc:cx.ckm00192201413.b1 -l
iscsiadm -m node -T iqn.1992-04.com.emc:cx.ckm00192201413.a1 -l
iscsiadm -m node -T iqn.1992-04.com.emc:cx.ckm00192201413.a0 -l

# Enable/Start service 
systemctl enable iscsid iscsi && systemctl stop iscsid iscsi && systemctl start iscsid iscsi
```

### Rescan BUS

```bash
for BUS in /sys/class/scsi_host/host*/scan; do  echo "- - -" >  ${BUS} ; done

sudo sh -c 'for BUS in /sys/class/scsi_host/host*/scan; do  echo "- - -" >  ${BUS} ; done '
```

* Partition your FS


* Becarefull to FSTAB errors:

  - First use UUID of the disk
  - Instead of default use _netdev in the fstab
  - Use option 0 0

```bash
echo "/dev/mapper/syno-syno   /backup                    ext4   _netdev   0 0" >> /etc/fstab
```

### Case of adding a Syno Volume as ISCSI 

```bash
yum install -y iscsi-initiator-utils

node=`hostname | cut -d"." -f1 | cut -d"-" -f3 | sed 's/data//'`
env=`hostname | cut -d"." -f1 | cut -d"-" -f2`

echo "InitiatorName=iqn.1994-05.com.redhat:my-${env}-nas${node}" > /etc/iscsi/initiatorname.iscsi

if ! grep -q SELINUX=permissive /etc/sysconfig/selinux;
then
        sed -e 's/^SELINUX\=.*/SELINUX=permissive/' -i /etc/sysconfig/selinux;
        setenforce 0;
        msg_ok "SELinux permissive mode activated (Needed for ISCSI with Syno).";
else
msg_ok "SELinux already in permissive mode (Needed for ISCSI with Syno)."
fi

systemctl enable iscsid iscsi && systemctl stop iscsid iscsi && systemctl start iscsid iscsi

iscsiadm --mode discovery --type sendtargets --portal 172.16.239.10
iscsiadm -m node -T iqn.2000-01.com.synology:MY-SYNO.exportdb-${env} -l
iscsiadm -m session -P 0

if ! grep -q backup /etc/fstab;
then
        mkdir /backup
        echo "/dev/mapper/syno-syno   /backup                    ext4   _netdev   0 0" >> /etc/fstab
        msg_ok "/backup Set in /etc/fstab."
else
        msg_warn "/backup is already in FSTAB - check if this is normal."
fi

mount -a
chown -R oracle:oinstall /backup
msg_ok "Backup Syno configured and mounted."
df -TPh /backup
```

### Umount ISCSI Disk

```bash
# get the sessions first
iscsiadm -m session -P 0

# remove the sessions
iscsiadm -m node -T iqn.1992-04.com.emc:cx.ckm00192201413.a0 -o delete
iscsiadm -m node -T iqn.1992-04.com.emc:cx.ckm00192201413.a1 -o delete
iscsiadm -m node -T iqn.1992-04.com.emc:cx.ckm00192201413.b0 -o delete
iscsiadm -m node -T iqn.1992-04.com.emc:cx.ckm00192201413.b1 -o delete

iscsiadm -m node --targetname "iqn.2000-01.com.synology:MY-SYNO.exportdb-${myENV}" --portal "${mySYNO}" --logout
iscsiadm -m discovery --portal "${mySYNO}" --op=delete
systemctl disable iscsid iscsi && systemctl stop iscsid iscsi
```


### Change IQN 

* Create an IQN

```bash
/sbin/iscsi-iname
```

* Make the change

```bash
cat /etc/iscsi/initiatorname.iscsi
InitiatorName=iqn.1988-12.com.oracle:614056c1ec93
```

* Umount

```bash
iscsiadm -m node -U all
service iscsid restart
service iscsi restart
```
