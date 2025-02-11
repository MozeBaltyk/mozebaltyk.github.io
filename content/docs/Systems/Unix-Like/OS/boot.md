---
date: 2023-08-01T21:00:00+08:00
title:  👢 Boot
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Linux
categories:
  - Systems
---


## The Boot - starting process 
	- BIOS est lancé automatiquement et détecte les périphs.
	- Charge la routine de démarrage depuis le MBR (Master Boot Record) - C'est le disk de boot et se trouve sur le premier secteur du disque dur.
	- Le MBR contient un loader qui charge le "second stage loader"  c'est le "boot loader" qui est propre au système qu'on charge.
		-> linux a LILO (Linux Loader) ou GRUB ( Grand Unified  Bootloader)
	- LILO charge le noyau en mémoire, le décompresse et lui passe les paramètres.
	- Le noyau monte le FS / (à partir de là, les commandes dans /sbin et /bin sont disponibles)
	- Le Noyau exécute le premier procès "init" 

## Conf LILO 
LILO peut avoir plusieurs Noyaux comme choix. Le choix par default : "Linux".
/etc/lilo.conf : Config des parametres du noyau  
/sbin/lilo : pour que les nouveaux params soient enregistrés. 
	-> créé le fichier /boot/map  qui contient les blocs physiques où se trouve le prog de démarrage.
	
Paramètres possibles " nom = valeur "
	- Boot : localisation du LILO
	- Install : chemin du "loader" - par défaut /boot/boot.b
	- Prompt : si option présente alors envoi une invite et attendra la saisie utilisateur.
	- Timeout : a utiliser avec prompt, délai d'attente avant de lancer le noyau par default.
	- Default :  nom de l'image a charger par default.
	- Image : chemin d'accès du noyau.
	- Label : nom donné au système.
	- Root : partition qui contient le système de fichier racine.
	- append : sont les params passer au boot du système dans la config .

## Conf GRUB
/sbin/grub  : pour modifier la config dans /boot/grub/grub.conf ou /boot/grub/menu.lst lu par /sbin/grub-install lors du démarrage. 


EFI
efibootmgr  :  Boot Order
efibootmgr -o 0012,0013,0002,0000,0001,0003,0004,0005,0006,0007,0008,0009,000C,0010,000E,000B,000F,000D,000

FS vfat /boot/efi  

efi_mirror -x


## GRUB 

cat /proc/cmdline  :  montre les parametres passes au kernel au moment du boot
cat /etc/grub.conf   : param a passer au kernel au moment du boot
/!\ grub-install /dev/sda

/etc/grub.d/00_header  => load /etc/default/grub (Le reste de /etc/grub.d/ est charge par ordre alphabetic)

Tout changement dans [ vi /etc/default/grub ] doit etre prise en compte dans /boot :
	BIOS based : grub2-mkconfig -o /boot/grub2/grub.cfg
	EFI  based : grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg

```bash
# List all Kernel propose on Boot
grubby --info=ALL | grep vmlinuz
kernel=/vmlinuz-2.6.32-754.3.5.el6.x86_64
kernel=/vmlinuz-2.6.32-696.18.7.el6.x86_64
kernel=/vmlinuz-2.6.32-696.13.2.el6.x86_64

# Show the kernel that it will boot
grubby --default-kernel
/boot/vmlinuz-3.10.0-957.1.3.el7.x86_64
```


## Initrd 

```bash
/etc/ecsi_linux_version
dracut /dev/sda
efi_mirror -x
```