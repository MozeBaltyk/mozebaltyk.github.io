---
date: 2023-08-25T21:00:00+08:00
title: 🍻 SSHFS
navWeight: 550 # Upper weight gets higher precedence, optional.
series:
  - Unix-Like
  - Disk
  - SSH
categories:
  - Systems
---


## SSHFS
SshFS sert à monter sur son FS, un autre système de fichier distant, à travers une connexion SSH, le tout avec des droits utilisateur. L'avantage est de manipuler les données distantes avec n'importe quel gestionnaire de fichier (Nautilus, Konqueror, ROX, ou même la ligne de commande).

	- Pre-requis : droits d'administration, connexion ethernet, installation de FUSE et du paquet SSHFS.
	- Les utilisateurs de sshfs doivent faire partie du groupe fuse.
	
Rq : FUSE permet à un utilisateur de monter lui-même un système de fichier. Normalement, pour monter un système de fichier, 
il faut être administrateur ou que celui-ci l'ait prévu dans « /etc/fstab » avec des informations en dur. 

	
sshfs [user@]host:[dir] mountpoint [options]    :   Monter un FS en SSHFS 
fusermount -u tmp    :   pour demonter
sshfs -o uid=xxxx -o gid=yyyy [user@]host:[dir] mountpoint [options] :  le rep monte, a un UID et GUID differents que celui attendu par le client. Donc preciser l'UID et le GUID qu'il doit avoir pour etre compatible avec le client.
fusauto /point/de/montage  :  demonter/monter 

Dans /etc/fstab, exemple :
=> conf qui pose probleme avec la commande umount : 
sshfs#user@machine:/dossier/distant     /mnt/mon_rep     fuse     port=22,user,noauto,noatime     0 0
=>  preferer cette syntaxe :
user@machine:/dossier/distant      /mnt/mon_rep    fuse.sshfs    port=22,user,noauto,noatime     0 0

Montage a la connexion de l'utilisateur 
en mettant la commande sshfs dans le .bash_profile de l'utilisateur.
