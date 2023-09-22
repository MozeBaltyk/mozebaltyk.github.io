---
date: 2023-08-27T21:00:00+08:00
title: 🐛 NFS
navWeight: 530 # Upper weight gets higher precedence, optional.
series:
  - Unix-Like
  - Disk
categories:
  - Systems
---

## The Basics  

Difference entre NFS et iscsi 
	- NFS gere mieux plusieurs Client en ecriture sur un meme share.
	- NFS c'est filesystem , iscsi c'est niveau block
	- iscsi performance  similaire au NFS. 
	- iscsi apparait comme un disk pour l'OS ( present dans "lsblk" ) / ce n'est pas le cas pour NFS  

Concurrent access to a block device like iSCSI is not possible with standard file systems. You'll need a shared disk filesystem (like GFS or OCSFS) to allow this, but in most cases the easiest solution would be to just use a network share (via SMB/CIFS or NFS) if this is sufficient for your application. 

Server side 
sudo yum install nfs-utils
sudo systemctl enable --now nfs-server rpcbind

sudo firewall-cmd --add-service={nfs,mountd,rpc-bind} --permanent 
sudo firewall-cmd --reload 

sudo setsebool -P nfs_export_all_rw 1


vi /etc/exports 
/backup 172.16.119.150(rw,async,root_squash)
/backup 172.16.119.151(rw,async,root_squash)

/bin/systemctl start nfs-server.service
exportfs -rav
showmount -e  : show exports from server side 
showmount -a  : show client which are currently mounting

Client Side
showmount --exports 172.16.239.10
Export list for 172.16.239.10:
/volume2/exportdb-dev-nfs 172.16.239.1,172.16.239.2,172.16.239.102,172.16.239.101
/volume1/exportdb         172.16.233.0/24

firewall-cmd --zone=backup --add-service=nfs --permanent
firewall-cmd --reload

mount -t nfs 172.16.239.10:/volume2/exportdb-dev-nfs /backup_tmp

chown -R oracle:oinstall /backup_tmp/
chmod -R 644 /backup_tmp/

nfsstat -m  :   all NFS mounts


/etc/fstab pour RMAN Backup
172.16.239.10:/volume2/exportdb-dev-nfs /backup nfs hard,rw,noac,rsize=32768,wsize=32768,proto=tcp,vers=4 0 1