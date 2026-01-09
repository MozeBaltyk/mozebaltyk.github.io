---
date: 2023-08-26T21:00:00+08:00
title: 🎶 Samba / CIFS
navWeight: 540 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Systems
  - Unix-Like
  - Disks
  - Shared-Storage
---

## Server Side

First Install samba and samba-client (for debug + test)

* `/etc/samba/smb.conf`
```ini
[home]
Workgroup=WORKGROUP (le grp par defaul sur windows)
Hosts allow = ...
[shared]
browseable = yes
path = /shared
valid users = user01, @un_group_au_choix
writable = yes
passdb backend = tdbsam #passwords are stored in the /var/lib/samba/private/passdb.tdb file.
```

### Test samba config  

`testparm`     

`/usr/bin/testparm -s /etc/samba/smb.conf`

`smbclient -L \192.168.56.102 -U test` : list all samba shares available

`smbclient //192.168.56.102/sharedrepo -U test ` : connect to the share

`pdbedit -L` : list user smb  (better than smbclient)

`smbstatus` : see all connexions on going

`/var/log/samba/estat-nalnfssmb/`

### Create User

```bash
# create an user
useradd -s /sbin/nologin user01

# Add user with samba client
smbpasswd -a user01

# Delete user 
smbpasswd -x user01

# Start Samba
systemctl enable smb nmb 
systemctl start smb nmb 
```

### Securite 

* Selinux

```bash
yum install -y setroubleshoot-server
semanage fcontext -a -t samba_share_t "/shared(/.*)?"
restorecon -RFv  /shared

# set boolean for smbd_anon_write

# user connexion to get its homedir
setsebool -P samba_enable_home_dirs=on  
```

* Firewalld

```bash
firewall-cmd --permanent --add-service=samba
firewall-cmd --reload
```

## Client Side 

First install cifs-utils

* Mount
```bash
mount -o username=fred credentials=xxx //server/shared  /point/mnt
``` 

```shell
mount -o multiuser, sec=ntlmssp, username=fred //server/shared  /point/mnt    
 |__ premier connexion fait avec le compte root pour un des user samba (celui qui a le moins de droits)
			|__ cifscreds (-u user) add / update / clear server7  : les autres users peuvent se connecter a ce partage
```

## Test Connexion with Windows Domains

```bash
net -s /etc/samba/smb.conf ads join createcomputer='OU=DC-Unix-Servers,OU=Computers,OU=Common Services,DC=net1,DC=example,DC=com' -Uramdomuser
Enter ramdomuser's password:
Using short domain name -- NET1
Joined 'SERVER' to dns domain 'net1.example.com'
kerberos_kinit_password SERVER$@NET1.EXAMPLE.COM failed: Client not found in Kerberos database
DNS Update for server.example.com failed: ERROR_DNS_GSS_ERROR
DNS update failed!

net -d5 -s /etc/samba/smb.conf ads join createcomputer='OU=DC-Unix-Servers,OU=Computers,OU=Common Services,DC=net1,DC=example,DC=com' -Uxxxxxxxx

net ads testjoin
Join is OK
```
