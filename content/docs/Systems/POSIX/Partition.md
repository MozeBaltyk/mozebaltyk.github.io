---
date: 2023-08-30T21:00:00+08:00
title: 🗿 Partition
navWeight: 500 # Upper weight gets higher precedence, optional.
series:
  - Unix-Like
  - Disk
categories:
  - Systems
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

## Create Partition 1 on all disk sdb 

in script mode
```bash
sudo parted /dev/sdb -s \
 -a optimal\
 mklabel gpt\
 mkpart primary 1 100%\
 set 1 lvm on
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

Les Disques Durs

	1. Pour les disques SCSI ou SATA, la numérotation se fait avec un préfixe sd, suivi par une lettre.
		Attention : les lecteurs de CD-ROM SCSI, les ZIP, JAZ, etc. SCSI ainsi que les périphériques de stockage USB (appareils photo, clefs USB...) apparaissent comme un disque dur SCSI ; ils se nomment aussi sdx suivant leur ID. 
		Astuce : pour connaître la liste de vos périphériques de ce type, tapez : cdrecord -scanbus.
	
	2. pour les disques IDE (ou aussi Parallel-ATA), la numérotation se fait avec un préfixe hd, suivi par une lettre, « a » pour le premier IDE maître, « b » pour le premier esclave,
							} hda Disque maître sur le 1er contrôleur IDE
							} hdb Disque esclave sur le 1er contrôleur IDE
							} hdc Disque maître sur le 2eme contrôleur IDE
							} hdd Disque esclave sur le 2eme contrôleur IDE
							
	3. Les Array - mdX  ( md0 ) :  vu comme un disk mais c'est du RAID logiciel gere par mdadm. 
	4. Disk virtuel = vda 
	
	
Type de Partitionnement
	5 => partitions etendues
	7 => NTFS Windows 
	82 => SWAP
	83 => partition standard (necessaire par exemple pour le /boot)
	8e => partition LVM

Rappel :  le nombre de partitions dites "primaires" est limité à 4. Ainsi, on veut définir plus de 4 partitions sur un même disque, l'une de ces 4 partitions primaires doit être définie comme "étendue", on ajoutera des partitions "logiques".

Remarque : la philosophie  BSD  est differente (on voit ca aussi chez Solaris) :
			- la partition est divise en slice jusqu'a 8 (de 0 a 7)
			- Le nommage des disks IDE se fait par cXtXdX  (c = controler, t = target, d = device)


## Partition Tools

⚠️ commandes qui peuvent detruire un disk
fdisk  :  outil interactif  pour partitionner un disk (comprend les tables DOS, BSD et SUN). 
fdisk -cu /dev/sdb : preferable  car -c desactive le mode DOS, -u pour listes les partitions en secteurs et non en cylindres)
Rq : fdisk -l donne la table de partition sans rentrer dans le mode commande mais apres si on veut travailler sur les disks, on passe en mode commande)
		|->  p : affiche la table de partition
		|->  n : ajouter une partition
		|->  d : detruire une partition
		|->  o : creer une table de partition vide pour un nouveau disk
		|->  t : change le type d'une partition
		"w"  pour ecrire et sortir / "q" pour quitter sans sauvegarder  (mais tjrs necessaire de redemarrer pour prendre en cpte les modif)  
		
sfdisk   :    Manipulateur de tables de partitions pour Linux en Scriptable  
sfdisk -s [partition]   :  liste les partitions et leurs tailles en "blocks" 
sfdisk -l [périphérique]   :  listera les partitions du périphérique voulu ou de tous les perif. 
						(les + et - dans le resultat signifie que la valeur a ete arrondi au -dessus ou en dessous) 
sfdisk -V [périphérique]   :  fait des tests sur la table des partitions du périphérique, renvoie  « OK » ou se plaindra. 
						(avec -q renvoie que le code retour, utile pour les script)
sfdisk -d   :  Produire les partitions d'un périphérique dans un format convenant comme entrée pour sfdisk. (utile pour la reconstruction d'un mirroir)

cfdisk   :  Outil interactif (plus conviviale que fdisk)

Parted => Better than fdisk 