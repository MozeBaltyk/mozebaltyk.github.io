---
date: 2024-10-01T21:00:00+08:00
title:  👢 Boot
nav_weight: 10 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
---


## The Boot - starting process 
	- The BIOS is started automatically and detects the peripherals.
	- Loads the boot routine from the MBR (Master Boot Record) - it is the boot disk, located on the first sector of the hard disk.
	- The MBR contains a loader that loads the "second stage loader": this is the "boot loader" specific to the system being loaded.
		-> Linux uses LILO (Linux Loader) or GRUB (Grand Unified Bootloader).
	- LILO loads the kernel into memory, decompresses it, and passes it the parameters.
	- The kernel mounts the `/` filesystem (from there, the commands in `/sbin` and `/bin` are available).
	- The kernel runs its first process: `init`.

{{< bs/alert warning >}}
{{< markdownify >}}
LILO is a legacy bootloader (obsolete), superseded by GRUB and now GRUB2. The LILO section below is kept for historical reference.
{{< /markdownify >}}
{{< /bs/alert >}}

## LILO configuration 
LILO can offer several kernels as choices. The default choice: "Linux".
`/etc/lilo.conf` : configuration of the kernel parameters.
`/sbin/lilo` : to write the new parameters to disk.
	-> creates the `/boot/map` file, which contains the physical blocks where the boot program is located.
	
Possible parameters " name = value "
	- Boot : location of LILO.
	- Install : path of the "loader" - default `/boot/boot.b`.
	- Prompt : if present, displays a prompt and waits for user input.
	- Timeout : used with Prompt, the delay before booting the default kernel.
	- Default :  name of the image to load by default.
	- Image : path of the kernel.
	- Label : name given to the system.
	- Root : partition containing the root filesystem.
	- append : parameters passed to the system at boot.

## GRUB configuration
`/sbin/grub` : to modify the config in `/boot/grub/grub.conf` or `/boot/grub/menu.lst`, read by `/sbin/grub-install` at startup.


EFI
`efibootmgr`  :  Boot Order
`efibootmgr -o 0012,0013,0002,0000,0001,0003,0004,0005,0006,0007,0008,0009,000C,0010,000E,000B,000F,000D,000`

FS vfat `/boot/efi`


## GRUB 

`cat /proc/cmdline`  :  shows the parameters passed to the kernel at boot.
`cat /etc/grub.conf`   : parameters to pass to the kernel at boot.
`/!\ grub-install /dev/sda`

`/etc/grub.d/00_header`  => loads `/etc/default/grub` (the rest of `/etc/grub.d/` is loaded in alphabetical order).

Any change in [ `vi /etc/default/grub` ] must be taken into account in `/boot` :
	BIOS based : `grub2-mkconfig -o /boot/grub2/grub.cfg`
	EFI  based : `grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg`

```bash
# List all kernels available at boot
grubby --info=ALL | grep vmlinuz
kernel=/vmlinuz-2.6.32-754.3.5.el6.x86_64
kernel=/vmlinuz-2.6.32-696.18.7.el6.x86_64
kernel=/vmlinuz-2.6.32-696.13.2.el6.x86_64

# Show the kernel that will boot
grubby --default-kernel
/boot/vmlinuz-3.10.0-957.1.3.el7.x86_64
```


## Initrd 

```bash
/etc/ecsi_linux_version
dracut /dev/sda
```