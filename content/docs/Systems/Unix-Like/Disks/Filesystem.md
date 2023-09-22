---
date: 2023-08-29T21:00:00+08:00
title: 📂 Filesystem
navWeight: 510 # Upper weight gets higher precedence, optional.
series:
  - Unix-Like
  - Disk
categories:
  - Systems
---


##  FS Types
`ext4` :  le plus répandu sous GNU/Linux (issu de ext2 et ext3). Il est journalisé, c'est à dire qu'il trace les opérations d'écriture pour garantir l'intégrité des données en cas d'arrêt brutal du disque. De plus, il peut gérer des volumes de taille jusque 1 024 pébioctets et permet la pré-allocation d'une zone contiguë pour un fichier, afin de minimiser la fragmentation. Utilisez ce système de fichiers si vous comptez pouvoir relire des informations depuis votre Mac OS X ou Windows.

`ReiserFS` : C'est un système de fichiers journalisé qui a été réimplémenté à partir de zéro et bénéficie de beaucoup d'innovations. Il est plus rapide qu'ext4 pour le traitement de répertoires contenant des milliers de fichiers de petite taille. Il permet l'agrandissement à chaud et la diminution à froid de la taille des partitions

`BTRFS` : similaire a ZFS

`Ufs` : pour FreeBSD et Solaris   |  Vxfs : Pour HP-UX  |  JFS : Pour AIX

## Listages et Verifications FS
df -Th :   lister les FS et voir l'espace libre (-T type de FS, -h human Reading)
mount -a : Voir les FS montes. (S'appui sur /proc/mounts)
[RHEL] findmnt :   voir les FS montés de manière plus lisible.

fsck  :  check fs (a faire que si le FS est demonte)
fsck -y /dev/mapper/vgdata-etc

Creation et Exploitation
mkfs -t ext4 /dev/hda3  : pour creer un type de filesystem sur un partition hda = choix du disk / 3 = a la partition.
mkfs.ext4 /dev/vdb3   :  (remplacer ext4 avec ce qu'on veut)

mount /dev/dsk/sda /mon_fs    |  
	 umount  : monter/demonter un FS,  
	 umount -lf /ec/dev/app 
mount -o remount,ro /usr  :   remonter (sans interuption de service) en "Read Only" le FS /usr
mount -o remount,rw /usr  :   remonter (sans interuption de service) en "Read Write" le FS /usr


## Check mount 
[root@bcp-int-ampa1 ~]# grep mqm  /var/log/messages
Oct 27 11:49:15 bcp-int-ampa1 systemd: Unit var-mqm.mount is bound to inactive unit dev-mapper-mqmclient\x2dvar_mqm.device. Stopping, too.
Oct 27 11:49:15 bcp-int-ampa1 systemd: Unmounting /var/mqm...

[root@bcp-int-ampa1 ~]# systemctl status /var/mqm
● var-mqm.mount - /var/mqm
   Loaded: loaded (/etc/fstab; bad; vendor preset: disabled)
   Active: inactive (dead) since Tue 2020-10-27 12:00:45 CET; 4min 0s ago
    Where: /var/mqm
     What: /dev/mapper/mqmclient-var_mqm
     Docs: man:fstab(5)
           man:systemd-fstab-generator(8)
  Process: 1978129 ExecUnmount=/bin/umount /var/mqm (code=exited, status=0/SUCCESS)

Oct 27 12:00:45 bcp-int-ampa1.int.bcp.psf systemd[1]: Unit var-mqm.mount is bound to inactive unit dev-mapper-mqmclient\x2dvar_mqm.device. Stopping, too.
Oct 27 12:00:45 bcp-int-ampa1.int.bcp.psf systemd[1]: Unmounting /var/mqm...
Oct 27 12:00:45 bcp-int-ampa1.int.bcp.psf systemd[1]: Unmounted /var/mqm.
Warning: var-mqm.mount changed on disk. Run 'systemctl daemon-reload' to reload units.


## Mount Bind 
mount --bind /mnt/sshfs/lrancid01ch /data/externes/rancidRANIP  : "mount --bind" pour associer deux repertoires
	On doit les retrouver dans le mount : mount | grep rancidRANIP
	/mnt/sshfs/lrancid01ch on /data/externes/rancidRANIP type none (rw,bind)


findmnt | fgrep [

resize2fs 
xfs_growfs -d /dev/mapper/vgdata-sw_oracle

Configuration
/etc/mnttab :  config Dynamic
/etc/fstab :  config Static
/proc/mounts :  vu par le Kernel


## FStab 
UUID="aaa-33-212122edwfs"   /mnt/point   ext4  defaults  0  0    # 0=No Backup / 0=no fsck au reboot
UUID="sss-555-343435346"    /mnt/autre   xfs   defaults  1  1    # 1=backup / 1 FS important pour le systeme
UUID="444-rrr-345234523"    /mnt/suivant  vfat  defaults  1  2   # 2=fsck - mais le systeme peut demarrer sans. 
UUID="111-4343-42342"       swap         swap  defaults  0  0    # SWAP 

/!\ Attention Error in your FSTAB: 
	- When adding a device to fstab, unless you are using LVM or a filesystem that supports snapshots*, use the UUID.
	- use UUID of the disk (except when using LVM)
	- Instead of default use _netdev in the fstab for iscsi
	- Use option 0 0 

From <https://xan.manning.io/2017/05/29/best-practice-for-mounting-an-lvm-logical-volume-with-etc-fstab.html> 


## Autofs : Montage Automatique
Autofs  : dans fstab ou en manuel, si la connexion internet se perd, alors le montage se stoppe. Autofs monte automatiquent les sshfs. Paquet a installer.

Options
Autre possibilite, mettre dans le /fstab, a la place de noauto, le parametre _netdev qui indique que c'est un repertoire reseau et qu'il faut attendre la connexion reseau avant de le monter. 

Parametrage Autofs : 
	- Besoin de s'authentifier automatiquement en ssh en root (contrairement a NFS) donc cle ssh necessaire.
			§ sudo ssh-keygen -t dsa   :  creation cle publique/privee
			§ /root/.ssh/id_dsa.pub  sur le client   |    ~/.ssh/authorized_keys   sur le serveur.
			§ sudo ssh-copy-id -i /root/.ssh/id_dsa.pub <utilisateur>@<ip serveur>  
						=> pour chaque utilisateur qui aura droit de se connecter au sshfs.
			§ Desactiver les SSHFS qui seront geres par l'Autofs, dans /fstab (commenter les lignes)
			§ Recuper l'UID et GUID des utilisateurs  ( cat /etc/passwd | grep benoit )
			§ Editer le fichier /etc/auto.master   avec  :
			/mnt   /etc/auto.sshfs  uid=1000,gid=1000, --timeout=30, --ghost
			(option --ghost permet d'afficher les dossiers meme quand ils ne sont pas montes)
			§ Puis dans /etc/auto.sshfs :
			mondossier -fstype=fuse,port=22,rw,allow_other :sshfs\#votrelogin@192.168.0.1\:/media/share
			(/mnt/mondossier pointera vers la machine 192.168.0.1 sur le répertoire /media/share)
			§ service autofs restart
			Si une passphrase a ete definit pour les cles SSH, faire ssh-add qui ajoute les fichiers .ssh/id_rsa et id_dsa dans le ssh-agent et du coup demande la passphrase.

Rq: Il existe aussi des modes Graphiques : voir fusauto ou encore Xsshfs

Autre Exemple avec AutoFS

Methode Classic dans /etc/fstab :
$ sudo mount -t cifs //192.168.1.1/partage /mnt/partage/ -o user=utux,vers=3.0

J'aimerai que ce soit automatique. Le problème est que je ne peux pas utiliser le /etc/fstab car au moment où il est exécuté le réseau n'est pas prêt (wifi ou client openvpn). Il existe bien l'option _netdev mais elle n'a jamais fonctionné pour moi. Ce cas d'usage montre bien les limites des montages Linux qui ne sont pas adaptés à la mobilité et aux environnements dynamiques.

Bonne nouvelle, il existe une alternative: autofs qui s'appuie sur automount. Contrairement à mount, il connecte le partage lorsqu'on y accède (et pas au démarrage) et le déconnecte si on ne l'utilise pas. Il a aussi de nombreuses autres fonctionnalités:
	• Un système de templates utile quand on a de nombreux partages.
	• Support de plusieurs protocoles (cifs, nfs, raw...).
	• Auto-découverte des partages.
	• Consommation de ressources moindre (déconnecte les partages non utilisés)
	• Meilleure tolérance aux coupures réseau.
	
	- Installation sous Debian / Ubuntu : $ sudo apt install autofs
	- Créer/éditer le /etc/auto.master:  /mnt	/etc/auto.nas --timeout 300 --browse
	- Créer/éditer le /etc/auto.nas:   
	partage -fstype=cifs,credentials=/home/utux/.autofs_creds,user=utux,vers=3.0 ://192.168.1.1/partage
	- Créer le fichier /home/utux/.autofs_creds :
			username=utux
password=secret
	- Mettre le /home/utux/.autofs_creds en chmod 0600:   $ chmod 0600 /home/utux/.autofs_creds
	- Mettre le /etc/auto.nas en chmod 0644 :   $ sudo chmod 0644 /etc/auto.nas
	- Démarrer le service:   $ sudo systemctl start autofs
	- Tester:   $ ls /mnt/partage
	- Si cela ne fonctionne pas:
		$ sudo systemctl stop autofs
$ sudo automount -f –v
	- Notez que cela ne fonctionnera pas si le /etc/auto.nas est exécutable:   $ sudo chmod -x /etc/auto.nas

Autofs est génial et solutionne mes problèmes de montage de partages en mobilité.

