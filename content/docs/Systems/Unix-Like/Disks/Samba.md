---
date: 2023-08-26T21:00:00+08:00
title: 🎶 Samba / CIFS
navWeight: 540 # Upper weight gets higher precedence, optional.
series:
  - Unix-Like
  - Disk
categories:
  - Systems
---

## Server Side

Install du package samba + (samba-client  pour les cptes + debug + test)
/etc/samba/smb.conf
	[home]
	Workgroup=WORKGROUP (le grp par defaul sur windows)
	Hosts allow = ...
	[shared]
	browseable = yes
path = /shared
valid users = user01, @un_group_au_choix
writable = yes
	passdb backend = tdbsam, passwords are stored in the /var/lib/samba/private/passdb.tdb file.

testparm :  Test de la config Samba
/usr/bin/testparm -s /etc/samba/smb.conf

smbclient -L \192.168.56.102 -U test   :   liste les partages samba dispo
smbclient //192.168.56.102/sharedrepo -U test  :  connecter a un depot 
pdbedit -L  :     liste user smb  (mieux que le smbclient)

smbstatus : Voir toutes les connexions en cours
/var/log/samba/estat-nalnfssmb/

Creation utilisateur
# useradd -s /sbin/nologin user01
=> apres le compte samba en NTLM ajout du compte avec le samba-client
# smbpasswd -a user01   :   ajout  |  smbpasswd -x user01  :   delete 
New SMB password: pass
Retype new SMB password: pass
Added user user01.
# systemctl start/ enable smb nmb 

Securite 
# yum install -y setroubleshoot-server
# semanage fcontext -a -t samba_share_t "/shared(/.*)?"
# restorecon -RFv  /shared
=> boolean   :  smbd_anon_write
# setsebool -P samba_enable_home_dirs=on  :   cnx d'un user et il obtient son home directory
# firewall-cmd --permanent --add-service=samba
# firewall-cmd --reload

## Client Side 
=> install cifs-utils

Montage 
mount -o username=fred credentials=xxx //server/shared  /point/mnt

mount -o multiuser, sec=ntlmssp, username=fred //server/shared  /point/mnt    
 |__ premier connexion fait avec le compte root pour un des user samba (celui qui a le moins de droits)
			|__ cifscreds (-u user) add / update / clear server7  : les autres users peuvent se connecter a ce partage
	

/etc/fstab


Test Connexion avec Domains Windows

net -s /etc/samba/smb.conf ads join createcomputer='OU=DC-Unix-Servers,OU=Computers,OU=Common Services,DC=net1,DC=cec,DC=eu,DC=int' -Ucarochr
Enter carochr's password:
Using short domain name -- NET1
Joined 'WLTS0529' to dns domain 'net1.cec.eu.int'
kerberos_kinit_password WLTS0529$@NET1.CEC.EU.INT failed: Client not found in Kerberos database
DNS Update for wlts0529.cc.cec.eu.int failed: ERROR_DNS_GSS_ERROR
DNS update failed!

net -d5 -s /etc/samba/smb.conf ads join createcomputer='OU=DC-Unix-Servers,OU=Computers,OU=Common Services,DC=net1,DC=cec,DC=eu,DC=int' -Uxxxxxxxx

net ads testjoin
Join is OK