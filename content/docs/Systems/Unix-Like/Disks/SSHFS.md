---
date: 2023-08-25T21:00:00+08:00
title: 🍻 SSHFS
nav_weight: 110 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
  - Storage
  - Networking
---


## SSHFS
SSHFS mounts a remote filesystem on your local filesystem through an SSH connection, all with user rights. The advantage is being able to manipulate remote data with any file manager (Nautilus, Konqueror, ROX, or even the command line).

	- Prerequisites: administrator rights, ethernet connection, installation of FUSE and the SSHFS package.
	- SSHFS users must belong to the `fuse` group.
	
Note: FUSE allows a user to mount a filesystem themselves. Normally, mounting a filesystem requires being an administrator, or having it pre-approved in `/etc/fstab` with hard-coded information.

	
sshfs [user@]host:[dir] mountpoint [options]    :   Mount a filesystem over SSHFS.
fusermount -u tmp    :   to unmount.
sshfs -o uid=xxxx -o gid=yyyy [user@]host:[dir] mountpoint [options] :  the mounted directory has a different UID/GID than the one expected by the client, so specify the UID/GID it must have to be compatible with the client.
fusauto /point/de/montage  :  unmount/mount.

In `/etc/fstab`, example:
=> config that causes a problem with the `umount` command:
sshfs#user@machine:/remote/dir     /mnt/my_dir     fuse     port=22,user,noauto,noatime     0 0
=>  prefer this syntax:
user@machine:/remote/dir      /mnt/my_dir    fuse.sshfs    port=22,user,noauto,noatime     0 0

Mount at the user's login
by putting the `sshfs` command in the user's `.bash_profile`.