---
date: 2024-08-01T21:00:00+08:00
title: Disks ASM
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - DBA
tags:
  - Oracle
  - Storage
---

## Basics

* Start ASM - The old way:

```bash
. oraenv     # ora SID = +ASM1 (if second nodes +ASM2 )
sqlplus / as sysasm
startup
```

* Start ASM - The new method:

```bash
srvctl start asm -n ora-node1-hostname
```

* Check ASM volumes

```bash
srvctl status asm
asmcmd lsdsk
asmcmd lsdsk -G DATA
srvctl status diskgroup -g DATA
```

* Check clients connected to ASM volume

```bash
# List clients
asmcmd lsct

DB_Name  Status     Software_Version  Compatible_version  Instance_Name  Disk_Group
+ASM     CONNECTED        19.0.0.0.0          19.0.0.0.0  +ASM           DATA
+ASM     CONNECTED        19.0.0.0.0          19.0.0.0.0  +ASM           FRA
MANA     CONNECTED        12.2.0.1.0          12.2.0.0.0  MANA           DATA
MANA     CONNECTED        12.2.0.1.0          12.2.0.0.0  MANA           FRA
MREPORT  CONNECTED        12.2.0.1.0          12.2.0.0.0  MREPORT        DATA
MREPORT  CONNECTED        12.2.0.1.0          12.2.0.0.0  MREPORT        FRA

# Files Open
asmcmd lsof

DB_Name  Instance_Name  Path
MANA     MANA           +DATA/MANA/DATAFILE/blob.268.1045299983
MANA     MANA           +DATA/MANA/DATAFILE/data.270.1045299981
MANA     MANA           +DATA/MANA/DATAFILE/indx.269.1045299983
MANA     MANA           +DATA/MANA/control01.ctl
MANA     MANA           +DATA/MANA/redo01a.log
MANA     MANA           +DATA/MANA/redo02a.log
MANA     MANA           +DATA/MANA/redo03a.log
MANA     MANA           +DATA/MANA/redo04a.log
MANA     MANA           +DATA/MANA/sysaux01.dbf
[...]
```

* Connect to ASM prompt

```bash
. oraenv # ora SID = +ASM
asmcmd
```

## ASMlib

* ASMlib - provide oracleasm command:

```bash
# list
oracleasm listdisks
DATA2
FRA1

# check
oracleasm status
Checking if ASM is loaded: yes
Checking if /dev/oracleasm is mounted: yes

# check one ASM volume
oracleasm querydisk -d DATA2
Disk "DATA2" is a valid ASM disk on device [8,49]

# scan
oracleasm scandisks
Reloading disk partitions: done
Cleaning any stale ASM disks...
Scanning system for ASM disks...
Instantiating disk "DATA3"

# Create, delete, rename
oracleasm createdisk DATA3 /dev/sdf1
oracleasm deletedisk
oracleasm renamedisk
```

* custom script to list disks handle for ASM (not relevant anymore):

```bash
cat asmliblist.sh
#!/bin/bash
for asmlibdisk in `ls /dev/oracleasm/disks/*`
  do
    echo "ASMLIB disk name: $asmlibdisk"
    asmdisk=`kfed read $asmlibdisk | grep dskname | tr -s ' '| cut -f2 -d' '`
    echo "ASM disk name: $asmdisk"
    majorminor=`ls -l $asmlibdisk | tr -s ' ' | cut -f5,6 -d' '`
    device=`ls -l /dev | tr -s ' ' | grep -w "$majorminor" | cut -f10 -d' '`
    echo "Device path: /dev/$device"
  done
```

## Disks Group

*Disk Group* : all disks in teh same DG should have same size. Different type of *DG*, external means that LUN replication is on storage side.
When a disk is added to DG wait for rebalancing before continuing operations. 

* Connect to ASM instance

```bash
# Find your ASM instance
ps -ef | grep asm_pmon
oracle   22338     1  0  2019 ?        00:13:57 asm_pmon_+ASM1

su - oracle
. oraenv +ASM1 
sqlplus / as sysasm
```

* Add/Remove disk to DG

```sql
-- Take in udev rule the names oracleasm/dataX
alter diskgroup DATA add disk '/dev/oracleasm/data3' NAME DATA_0003, '/dev/oracleasm/data4' NAME DATA_0004, '/dev/oracleasm/data5' NAME DATA_0005;

-- Follow up the rebalance 
select * from v$asm_operation;

-- Follow up the rebalance 2
set lines 200 pages 2000
select count(1) as COUNT from v$asm_operation;

-- Drop disk
ALTER DISKGROUP FRA DROP DISK FRA_0003 ;
ALTER DISKGROUP DATA DROP DISK DATA_0002 ;

-- Add several disks
alter diskgroup FRA add disk '/dev/oracleasm/fra3' NAME FRA_0003, '/dev/oracleasm/fra2' NAME FRA_0002;
```

* with GUI use `asmca`

* Check DG

```bash
. oraenv +ASM1
asmcmd lsdg

# Check if a disks was already added to DG in the past
od -c /dev/sdi | more
```

* See all disks:

```sql
set lines 200 pages 2000
col path for a40
select group_number, disk_number, name, path from v$asm_disk order by 1,2;
```

```txt
GROUP_NUMBER DISK_NUMBER NAME                           PATH
------------ ----------- ------------------------------ ----------------------------------------
           1           0 DATA_0000                      /dev/oracleasm/data1
           1           1 DATA_0001                      /dev/oracleasm/data2
           1           2 DATA_0003                      /dev/oracleasm/data3
           1           3 DATA_0004                      /dev/oracleasm/data4
           1           4 DATA_0005                      /dev/oracleasm/data5
           1           5 DATA_0006                      /dev/oracleasm/data6
           1           6 DATA_0007                      /dev/oracleasm/data7
           1           7 DATA_0008                      /dev/oracleasm/data8
           1           8 DATA_0009                      /dev/oracleasm/data9
           1           9 DATA_0010                      /dev/oracleasm/data10
           1          10 DATA_0011                      /dev/oracleasm/data11
           2           0 FRA_0000                       /dev/oracleasm/fra1
```

* Check the spaces usage on Disks:

```sql
set lines 200 pages 2000
col path for a60
select d.group_number, d.disk_number, g.name, d.name, d.header_status, d.mount_status, d.total_mb/1024 total_gb, d.free_mb/1024 free_gb, d.path
from v$asm_disk d, v$asm_diskgroup g
where d.group_number = g.group_number
order by 1,2
/
```

```txt
GROUP_NUMBER DISK_NUMBER NAME    NAME        HEADER_STATU MOUNT_S   TOTAL_GB    FREE_GB PATH
------------ ----------- -------------------------------- ------- ---------- ---------- ----------------------
           1           0 DATA    DATA_0000   MEMBER       CACHED  19.9960938    19.3125 /dev/oracleasm/data1
           1           1 DATA    DATA_0001   FORMER       CACHED  19.9960938   19.34375 /dev/oracleasm/data2
           1           2 DATA    DATA_0003   MEMBER       CACHED  19.9960938 19.3476563 /dev/oracleasm/data3
           1           3 DATA    DATA_0004   MEMBER       CACHED  19.9960938   19.34375 /dev/oracleasm/data4
           1           4 DATA    DATA_0005   MEMBER       CACHED  19.9960938   19.34375 /dev/oracleasm/data5
           1           5 DATA    DATA_0006   MEMBER       CACHED  19.9960938 19.3476563 /dev/oracleasm/data6
           1           6 DATA    DATA_0007   MEMBER       CACHED  19.9960938 19.3515625 /dev/oracleasm/data7
           1           7 DATA    DATA_0008   MEMBER       CACHED  19.9960938 19.3554688 /dev/oracleasm/data8
           1           8 DATA    DATA_0009   MEMBER       CACHED  19.9960938 19.3515625 /dev/oracleasm/data9
           1           9 DATA    DATA_0010   MEMBER       CACHED  19.9960938   19.34375 /dev/oracleasm/data10
           1          10 DATA    DATA_0011   MEMBER       CACHED  19.9960938   19.34375 /dev/oracleasm/data11
           2           0 FRA     FRA_0000    MEMBER       CACHED  19.9960938 13.8984375 /dev/oracleasm/fra1
```

* Check general space on ASM volume:

```sql
SET LINES 350
COL NAME FORMAT A30
SELECT NAME, TYPE, ROUND(TOTAL_MB/1024) TOTAL_GB,ROUND(FREE_MB/1024) "FREE_GB" FROM V$ASM_DISKGROUP
/
```

```txt
NAME                           TYPE     TOTAL_GB    FREE_GB
------------------------------ ------ ---------- ----------
DATA                           EXTERN        220        213
FRA                            EXTERN         20         14
```

* Check the content of ASM:

```sql
col gname form a10
col dbname form a10
col file_type form a14
SELECT
    gname,
    dbname,
    file_type,
    round(SUM(space)/1024/1024) mb,
    round(SUM(space)/1024/1024/1024) gb,
    COUNT(*) "#FILES"
FROM
    (
        SELECT
            gname,
            regexp_substr(full_alias_path, '[[:alnum:]_]*',1,4) dbname,
            file_type,
            space,
            aname,
            system_created,
            alias_directory
        FROM
            (
                SELECT
                    concat('+'||gname, sys_connect_by_path(aname, '/')) full_alias_path,
                    system_created,
                    alias_directory,
                    file_type,
                    space,
                    level,
                    gname,
                    aname
                FROM
                    (
                        SELECT
                            b.name            gname,
                            a.parent_index    pindex,
                            a.name            aname,
                            a.reference_index rindex ,
                            a.system_created,
                            a.alias_directory,
                            c.type file_type,
                            c.space
                        FROM
                            v$asm_alias a,
                            v$asm_diskgroup b,
                            v$asm_file c
                        WHERE
                            a.group_number = b.group_number
                        AND a.group_number = c.group_number(+)
                        AND a.file_number = c.file_number(+)
                        AND a.file_incarnation = c.incarnation(+) ) START WITH (mod(pindex, power(2, 24))) = 0
                AND rindex IN
                    (
                        SELECT
                            a.reference_index
                        FROM
                            v$asm_alias a,
                            v$asm_diskgroup b
                        WHERE
                            a.group_number = b.group_number
                        AND (
                                mod(a.parent_index, power(2, 24))) = 0
                            and a.name like '&&db_name'
                    ) CONNECT BY prior rindex = pindex )
        WHERE
            NOT file_type IS NULL
            and system_created = 'Y' )
WHERE
    dbname like '&db_name'
GROUP BY
    gname,
    dbname,
    file_type
ORDER BY
    gname,
    dbname,
    file_type
/
```

```txt
GNAME      DBNAME     FILE_TYPE              MB         GB     #FILES
---------- ---------- -------------- ---------- ---------- ----------
DATA       HCBS       CONTROLFILE            32          0          1
DATA       HCBS       DATAFILE           290692        284         22
DATA       HCBS       ONLINELOG           24640         24          8
DATA       HCBS       PARAMETERFILE           4          0          1
DATA       HCBS       PASSWORD                0          0          1
DATA       HCBS       TEMPFILE             6996          7          2
FRA        HCBS       AUTOBACKUP           7252          7        259
FRA        HCBS       CONTROLFILE            32          0          1
FRA        HCBS       ONLINELOG            1632          2          8
```


## Udev rules 

In Linux disks name can change after reboot depending the order and numbers of disks. Udev rules allow to give a nickname to a WWID. 

* Standard case:

```bash
#Get the disk's UUID 
/lib/udev/scsi_id -g -u /dev/sdh
36000d310004142000000000000000f21

# Config udev rules
vi /etc/udev/rules.d/99-oracleasm.rules
KERNEL==”sd?1″, ENV{ID_SERIAL}==”36005076380838362ac00000000000017″, SYMLINK+=”oracleasm/data1″, OWNER=”oracle”, GROUP=”oinstall”, MODE=”0660″

# Reload
/sbin/udevadm control --reload-rules
/sbin/udevadm trigger
```

* Multipath case:

```json
# Blacklist ASM inside /etc/multipath.conf following https://access.redhat.com/solutions/29537

blacklist {
       wwid "*"
       devnode "^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*"
       devnode "ofsctl"
       devnode "^asm/*"
}
```

```bash
# Get multipath aliases:
dmsetup ls --target multipath

orafraemc1      (249:7)
oralogemc1      (249:8)
oradataemc2     (249:9)
oradataemc1     (249:10)

udevadm info --query=all --name=/dev/mapper/orafraemc1

udevadm info --query=all --name=/dev/mapper/orafraemc1 | grep DM_UUID
E: DM_UUID=mpath-36006016053674d003493045f3896897f


# With the Alias
ENV{DM_NAME}=="orafraemc1", OWNER:="oracle", GROUP:="oinstall", MODE:="660"
ENV{DM_NAME}=="oralogemc1", OWNER:="oracle", GROUP:="oinstall", MODE:="660"
ENV{DM_NAME}=="oradataemc1", OWNER:="oracle", GROUP:="oinstall", MODE:="660"

# Second way 
ACTION=="add|change", ENV{DM_NAME}=="orafraemc1", OWNER="grid", GROUP="asmadmin", MODE="0660"

# With the UUID : 
ACTION=="add|change", ENV{DM_UUID}=="mpath-[DM_UUID]", SYMLINK+="udev-asmdisk1", GROUP="oinstall", OWNER="grid", MODE="0660"

# Reload udev rules
/sbin/udevadm control –reload-rules
/sbin/udevadm trigger
```

* Check with `ls -l` on the udev path will show on what it point:

```bash
# Wrong config:
ll /dev/oracleasm/disks/*
lrwxrwxrwx 1 root root 9 Jan  6 10:15 /dev/oracleasm/disks/DATAEMC1 -> ../../sdu
lrwxrwxrwx 1 root root 9 Jan  6 10:15 /dev/oracleasm/disks/DATAEMC2 -> ../../sdt
lrwxrwxrwx 1 root root 9 Jan  6 10:15 /dev/oracleasm/disks/FRAEMC1 -> ../../sdn
lrwxrwxrwx 1 root root 9 Jan  6 10:15 /dev/oracleasm/disks/LOGEMC1 -> ../../sdr

#Good Config: 
lrwxrwxrwx 1 root root 11 Mar 11 19:19 /dev/oracleasm/disks/NEWORADATA1 -> ../../dm-16
lrwxrwxrwx 1 root root 11 Mar 11 19:19 /dev/oracleasm/disks/NEWORADATA2 -> ../../dm-17
```

## AFD Disk Label

The Oracle ASMFD simplifies the configuration and management of disk devices by eliminating the need to rebind disk devices used with Oracle ASM each time the system is restarted.

The Oracle ASM Filter Driver rejects any I/O requests that are invalid. This action eliminates accidental overwrites of Oracle ASM disks that would cause corruption in the disks and files within the disk group. For example, the Oracle ASM Filter Driver filters out all non-Oracle I/Os which could cause accidental overwrites.

* Check if ASMlib is enable:

```bash
su - oracle
asmcmd afd_state
ASMCMD-9526: The AFD state is 'LOADED' and filtering is 'ENABLED' on host 'host'
```

* Checks labels on OS:

```bash
lsblk -o name,mountpoint,label,size,uuid

ls -l /dev/disk/by-label
lrwxrwxrwx. 1 root root 10 Sep 22 17:53 RAC1 -> ../../sdh1
lrwxrwxrwx. 1 root root 10 Sep 22 17:53 \x05 -> ../../sdi1
```

* List AFD label:

```bash
# Check one disk
asmcmd afd_lslbl /dev/sdq1
--------------------------------------------------------------------------------
Label                     Duplicate  Path
================================================================================
RAC2                                  /dev/sdq1

# Check all
asmcmd afd_lsdsk
--------------------------------------------------------------------------------
Label                     Filtering   Path
================================================================================
RAC2                        ENABLED   /dev/sdq1
```

* Label a disk:

```bash
$ORACLE_HOME/bin/asmcmd afd_label 'RAC2' '/dev/sdv1'
```

* Add a disk to AFD:

```bash
alter diskgroup data add disk 'AFD:DATA2';
```

* Remove a disk:

```bash
$ORACLE_HOME/bin/asmcmd afd_unlabel 'RAC1'
$ORACLE_HOME/bin/asmcmd afd_unlabel '/dev/sdv1'
```

* ASM config:

```bash
# List AFD 
su - oracle
. oraenv  #+ASM1
$ORACLE_HOME/bin/asmcmd dsget
parameter:AFD:*, /dev/oracleasm/*
profile:AFD:*,/dev/oracleasm/*

# Change it
asmcmd dsset 'AFD:*'
```
