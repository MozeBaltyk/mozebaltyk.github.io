---
date: 2023-08-03T21:00:00+08:00
title: 💾 Backup & Sync
nav_weight: 30 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
  - Storage
---

## Rsync

### The classic formula

```bash
rsync -arv --info=progress2 photo backup_photo
```

* `a` = archive — preserves permissions (owner, group), times, symbolic links and devices.
* `r` = recursive — copies directories and sub-directories.
* `v` = verbose — prints what is being copied.

### Examples

```bash
rsync -apvz --stats --update --exclude gsast/olap_cubes --exclude gsast/param   user@server-src:/export/ user@server-dest:/home/
rsync -av -e ssh root@192.168.1.10:/backup/DUMP/* .
rsync -azp --stats root@oracle-src:/ec/sw/oracle/client/product/12.2.0.1/network/mesg/ ~/mesg/
rsync -azp /home/user/mesg/ root@oracle-dest.example.com:/ec/sw/oracle/client/product/12.2.0.1/network/mesg/

ssh root@oracle-dest.example.com "ls -lrt /ec/sw/oracle/client/product/12.2.0.1/network/mesg/"
ssh root@oracle-dest.example.com "chown oracle:dc_dba /ec/sw/oracle/client/product/12.2.0.1/network/mesg/*"

rsync -aS --delete --rsh /export/home backup-host:/export/save
```

### Propagate deletions to the backup

If you delete files in the source directory, `rsync` does not propagate the deletion to the backup directory unless you add the `--delete` option.

If you don't want to delete the files entirely, you can place them in a separate directory with `--backup --backup-dir=`:

```bash
rsync -arv photo ~/backup_photo --delete --backup --backup-dir=~/backup_photo/delete
```

Of course, a remote backup is also possible:

```bash
rsync -arv photo user@backup-server:~/backup_photo --delete
```

Finally, in case your server isn't listening on SSH port 22, use the `-e` option, for example SSH on port 443: `-e 'ssh -p 443'`.