---
date: 2023-08-01T21:00:00+08:00
title:  📦 Archive
aliases:
  - /docs/systems/unix-like/disks/archive/
nav_weight: 20 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
  - Storage
---

## Tar - "tape archiver"

* Preserve files permissions and ownership. 

* The Basics

```bash
# Archive
tar cvf my_archive.tar <file1> <file2> </dir/folder/>

## Archive and compress with zstd everything in the current dir and push to /target/dir
tar -I zstd -vcf archive.tar.zstd -C /target/dir . 

# Extract
tar xvf my_archive.tar

# Extract and push to target dir 
tar -zxvf new.tar.gz -C /target/dir 
```

* Other useful options
  • t  :  list archive's content.
  • T  :  archive list given by a file.
  • P  :  preserve absolute path (useful for backing up /etc).
  • X  :  exclude.
  • z  :  gunzip compression.
  • j  :  bzip2 compression.
  • J  :  lzma compression.

* Other tricks

```bash
# move the whole directory tree to /opt_bis
tar cf - . | (cd /opt_bis ; tar xf - )

# Corrupt package - Unexpected EOF in archive
gunzip -c jakarta-tomcat-5.0.30.tar.gz | tar -xvf -
```

## Cpio - "Copy Input Output"

```bash
# Archive with cpio
ls | cpio -ov > /tmp/object.cpio

# Extract
cpio -idv < /tmp/object.cpio

# Extract and create the needed directories
cpio -i -make-directories

# With format
ls | cpio -ov -H tar -F sample.tar
cpio -idv -F sample.tar

# Check the content of a tar archive
cpio -it -F sample.tar

find /my/dir/to/move/ -depth | cpio -pmdv /mnt/out :  move a whole tree to another directory (without creating an archive)
  •  -p makes cpio use pass-through mode. It's like piping cpio -o into cpio -i.
  •  -d creates leading directories as needed in the target directory.
find . -print | cpio -pdmvu /opt_bis
```

## PAX

Created by POSIX, less popular than `tar`.

```bash
pax -wf my_archive.pax -x pax file1 file2   :   Archive
pax -wf my_archive.pax -x pax dir1/         :   Archive
pax -rf my_archive.pax                      :   Extract
pax -rzf my_archive.pax                     :   Extract a gzip archive
```

The main pax options are the following, and can be freely combined:
  • w / r : build / extract the archive;
  • f : use the file given as argument;
  • x <my_format> : archive format, default "ustar".
  • z : gunzip compression
  • j : bzip2 compression