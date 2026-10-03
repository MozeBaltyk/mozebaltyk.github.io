---
date: 2023-08-29T21:00:00+08:00
title: 📂 Filesystem
nav_weight: 20 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
  - Storage
---


##  FS Types

`ext4` :  the most widespread on GNU/Linux (derived from ext2 and ext3). It is journaled, meaning it records write operations to guarantee data integrity in case of an abrupt disk stop. It can also handle volumes up to 1 EiB (1024 PiB), and allows pre-allocating a contiguous area for a file to minimize fragmentation. Use this filesystem if you want to be able to read data back from macOS or Windows.

`ReiserFS` : A journaled filesystem that was reimplemented from scratch and benefits from many innovations. It is faster than ext4 at processing directories containing thousands of small files. It allows online growth and offline shrinking of partition sizes.

`BTRFS` : similar to ZFS.

`UFS` : for FreeBSD and Solaris   |   `VxFS` : for HP-UX   |   `JFS` : for AIX

## Listing and Verifying the FS

```bash
df -Th    # list the filesystems and see the free space (-T filesystem type, -h human readable)
mount -a  # see the mounted filesystems (relies on /proc/mounts)
findmnt   # see the mounted filesystems in a more readable way

fsck      # check a filesystem (only do it if the filesystem is unmounted)
fsck -y /dev/mapper/vgdata-etc
```

* FS Creation

```bash
mkfs -t ext4 /dev/hda3  # to create a filesystem type on a partition. hda = disk choice / 3 = the partition.
mkfs.ext4 /dev/vdb3     # (replace ext4 with whatever you want)

mount /dev/dsk/sda /my_fs
umount -lf /ec/dev/app 

mount -o remount,ro /usr   # remount (without service interruption) the /usr filesystem as "Read Only"
mount -o remount,rw /usr   # remount (without service interruption) the /usr filesystem as "Read Write"
```

## Bind Mount

```bash
mount --bind /mnt/sshfs/rancid-server /data/remote/rancid  : "mount --bind" to associate two directories
	It should then appear in mount : mount | grep rancid
	/mnt/sshfs/rancid-server on /data/remote/rancid type none (rw,bind)


findmnt | fgrep [

resize2fs 
xfs_growfs -d /dev/mapper/vgdata-sw_oracle

Configuration
/etc/mnttab :  dynamic configuration
/etc/fstab  :  static configuration
/proc/mounts :  as seen by the kernel
```

## FStab

```ini
UUID="aaa-33-212122edwfs"   /mnt/point   ext4  defaults  0  0    # 0=No backup / 0=no fsck at reboot
UUID="sss-555-343435346"    /mnt/other   xfs   defaults  1  1    # 1=backup / 1 important filesystem for the system
UUID="444-rrr-345234523"    /mnt/suivant  vfat  defaults  1  2   # 2=fsck - but the system can boot without
UUID="111-4343-42342"       swap         swap  defaults  0  0    # SWAP
```

/!\ Beware of errors in your FSTAB:

- When adding a device to fstab, unless you are using LVM or a snapshot-supporting filesystem*, use the UUID.
- use the UUID of the disk (except when using LVM).
- instead of `default`, use `_netdev` in fstab for iSCSI.
- Use option `0 0`.

## Autofs : auto-mount

Autofs : with fstab or a manual mount, if the network connection is lost, the mount stops. Autofs automatically mounts SSHFS. Package to install.

Options
Another possibility: put the `_netdev` parameter in fstab instead of `noauto`, which indicates that it is a network directory and to wait for the network connection before mounting.

Autofs configuration : 
	- Need to auto-authenticate over SSH as root (unlike NFS), so an SSH key is required.
			§ `sudo ssh-keygen -t dsa`   :  create the public/private key.
			§ `/root/.ssh/id_dsa.pub` on the client   |    `~/.ssh/authorized_keys`  on the server.
			§ `sudo ssh-copy-id -i /root/.ssh/id_dsa.pub <user>@<server ip>`  
						=> for each user that will be allowed to connect over SSHFS.
			§ Disable the SSHFS that will be managed by autofs in fstab (comment out the lines).
			§ Retrieve the UID and GID of the users  ( `cat /etc/passwd | grep jdoe` ).
			§ Edit the file `/etc/auto.master`  with  :
			/mnt   /etc/auto.sshfs  uid=1000,gid=1000, --timeout=30, --ghost
			(the --ghost option shows the folders even when they are not mounted)
			§ Then in `/etc/auto.sshfs` :
			mydir -fstype=fuse,port=22,rw,allow_other :sshfs\#youruser@192.168.0.1\:/media/share
			(/mnt/mydir will point to machine 192.168.0.1 on the /media/share directory)
			§ `service autofs restart`
			If a passphrase has been set for the SSH keys, run `ssh-add`, which adds the `.ssh/id_rsa` and `id_dsa` files to the ssh-agent and then asks for the passphrase.

Note: There are also GUI modes: see `fusauto` or `Xsshfs`.

Another example with AutoFS

Classic method in `/etc/fstab` :
```bash
$ sudo mount -t cifs //192.168.1.1/share /mnt/share/ -o user=jdoe,vers=3.0
```

I would like this to be automatic. The problem is that I cannot use `/etc/fstab`, because at the time it is executed the network is not ready (wifi or openvpn client). The `_netdev` option exists, but it has never worked for me. This use case shows well the limits of Linux mounts, which are not adapted to mobility and dynamic environments.

Good news, there is an alternative: `autofs`, which relies on `automount`. Unlike `mount`, it connects the share when you access it (and not at startup), and disconnects it when unused. It also has many other features:
	• A template system, useful when you have many shares.
	• Support for several protocols (cifs, nfs, raw...).
	• Auto-discovery of shares.
	• Lower resource consumption (disconnects unused shares).
	• Better tolerance to network interruptions.
	
	- Installation on Debian / Ubuntu : `$ sudo apt install autofs`
	- Create/edit `/etc/auto.master`:  `/mnt	/etc/auto.nas --timeout 300 --browse`
	- Create/edit `/etc/auto.nas`:   
	`share -fstype=cifs,credentials=/home/jdoe/.autofs_creds,user=jdoe,vers=3.0 ://192.168.1.1/share`
	- Create the file `/home/jdoe/.autofs_creds` :
			username=jdoe
			password=secret
	- Set `/home/jdoe/.autofs_creds` to chmod 0600:   `$ chmod 0600 /home/jdoe/.autofs_creds`
	- Set `/etc/auto.nas` to chmod 0644 :   `$ sudo chmod 0644 /etc/auto.nas`
	- Start the service:   `$ sudo systemctl start autofs`
	- Test:   `$ ls /mnt/share`
	- If it does not work:
		`$ sudo systemctl stop autofs`
		`$ sudo automount -f -v`
	- Note that this will not work if `/etc/auto.nas` is executable:   `$ sudo chmod -x /etc/auto.nas`

Autofs is great and solves my share-mounting problems when mobile.