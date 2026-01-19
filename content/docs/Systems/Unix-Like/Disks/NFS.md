---
date: 2023-08-27T21:00:00+08:00
title: 🐛 NFS
navWeight: 530 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Systems
  - Unix-Like
  - Disks
  - Shared-Storage
---

## The Basics  

NFS vs iscsi 
  - NFS can handle simultaniously writing from several clients.
  - NFS is a filesystem , iscsi is a block storage.
  - iscsi performance are same with NFS. 
  - iscsi will appear as disk to the OS, not the case for NFS.

Concurrent access to a block device like iSCSI is not possible with standard file systems. You'll need a shared disk filesystem (like GFS or OCSFS) to allow this, but in most cases the easiest solution would be to just use a network share (via SMB/CIFS or NFS) if this is sufficient for your application. 

## Server side 

* Install 
```bash
sudo yum install nfs-utils
sudo systemctl enable --now nfs-server rpcbind

sudo firewall-cmd --add-service={nfs,mountd,rpc-bind} --permanent 
sudo firewall-cmd --reload 

sudo setsebool -P nfs_export_all_rw 1
```

* Configure
```bash
vi /etc/exports 
/backup 172.16.119.150(rw,async,root_squash)
/backup 172.16.119.151(rw,async,root_squash)
```

* Start
```bash
/bin/systemctl start nfs-server.service
exportfs -rav
```

* Checks
```bash
# Show exports from server side
showmount -e  

# Show client which are currently mounting
showmount -a
```


## Client Side

* First check if you can access the export
```bash
showmount --exports 172.16.239.10
Export list for 172.16.239.10:
/volume2/exportdb-dev-nfs 172.16.239.1,172.16.239.2,172.16.239.102,172.16.239.101
/volume1/exportdb         172.16.233.0/24
```

* Open firewalld
```bash
firewall-cmd --zone=backup --add-service=nfs --permanent
firewall-cmd --reload
```

* Mount
```bash
mount -t nfs 172.16.239.10:/volume2/exportdb-dev-nfs /backup_tmp

chown -R oracle:oinstall /backup_tmp/
chmod -R 644 /backup_tmp/
```

* Checks
```bash
# show all NFS mounts
nfsstat -m
```

* Add to fstab
```bash
# Below an example for RMAN backup
172.16.239.10:/volume2/exportdb-dev-nfs /backup nfs hard,rw,noac,rsize=32768,wsize=32768,proto=tcp,vers=4 0 1
```
