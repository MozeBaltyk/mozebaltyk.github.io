---
date: 2023-08-01T21:00:00+08:00
title:  📦 Archive
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Systems
  - Unix-Like
  - Disks
---

## Tar - « tape archiver »

* Preserve files permissions and ownership. 

* The Basic

```bash
# Archive
tar cvf mon_archive.tar <fichier1> <fichier2> </rep/doosier/>

## Archive and compress with zstd everything in the current dir and push to /target/dir
tar -I zstd -vcf archive.tar.zstd -C /target/dir . 

# Extract
tar xvf mon_archive.tar

# Extract push to target dir 
tar -zxvf new.tar.gz -C /target/dir 
```

* Other usefull options
  • t  :  list archive's content.
  • T  :  Archive list given by a file.
  • P  :  Absolute path is preserve (usefull for backup /etc)
  • X  :  exclude
  • z  : compression Gunzip
  • j  : compression Bzip2
  • J  : compression Lzmacd

* Other tricks

```bash
# move all tree dir to /opt_bis
tar cf - . | (cd /opt_bis ; tar xf - )

# Package corrompu - Unexpected EOF in archive
gunzip -c jakarta-tomcat-5.0.30.tar.gz | tar -xvf -
```

## Cpio - "Copy Input Output"

```bash
# Archive with cpio
ls | cpio -ov > /tmp/object.cpio

# Extract
cpio -idv < /tmp/object.cpio

# Extract and make dir needed
cpio -i -make-directories

# With
ls | cpio -ov -H tar -F sample.tar
cpio -idv -F sample.tar

# Check the content of an archive tar
cpio -it -F sample.tar

find /mon/rep/a/deplacer/ -depth | cpio -pmdv /mnt/out :  deplacer tout un arbre vers un autre repertoire (sans faire une archive)
  •  -p makes cpio to use pass through mode. Its like piping cpio -o into cpio -i.
  •  -d creates leading directories as needed in the target directory.
find . -print | cpio -pdmvu /opt_bis
```

## PAX

Created by POSIX, less popular than `tar`.

```bash
pax -wf mon_archive.pax -x pax fichier1 fichier2   :   Archiver 
pax -wf mon_archive.pax -x pax dossier1/  :   Archiver 
pax -rf mon_archive.pax   :   Extraire 
pax -rzf mon_archive.pax   :   Extraire une archive gz
```

Les principales options de pax sont les suivantes et peuvent se combiner à souhait : 
  • w / r : construit / extrait l'archive ;
  • f : utilise le fichier donné en paramètre ;
  • x <mon_format> : format d'archive, par défaut « ustar ».
  • z : compression Gunzip
  • j : compression Bzip2
