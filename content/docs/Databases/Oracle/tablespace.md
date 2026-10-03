---
date: 2024-08-01T21:00:00+08:00
title: 🗄️ Tablespace
nav_weight: 60 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Databases
  - Storage
---

## Concepts

A **tablespace** (TBS) is a logical group of storage for data; each tablespace is made of one or more **datafiles** (`.dbf`), created on a disk (`TBS = 1.dbf + 2.dbf + …`). One datafile belongs to exactly one tablespace; a tablespace can have many datafiles. To grow a database you grow the datafiles of the required tablespace (which needs free space on the filesystem or ASM disk).

## View tablespaces & datafiles

```sql
SELECT * FROM dba_tablespaces;   -- the tablespaces.
SELECT * FROM dba_data_files;    -- the datafiles.
SELECT * FROM dba_temp_files;    -- the temporary files.
```

```sql
SELECT tablespace_name FROM dba_tablespaces;
```

Size & max size of a tablespace (interactive):

```sql
COL file_name FOR a60;
SELECT file_name, bytes/1024/1024/1024 AS dtf_gb, maxbytes/1024/1024/1024 AS dtf_max_gb, autoextensible
FROM dba_data_files WHERE tablespace_name = '&TABLESPACE_NAME';
```

Find the default tablespace of a user:

```sql
SELECT username, default_tablespace, temporary_tablespace FROM dba_users WHERE username = 'MY_USER';
SELECT default_tablespace FROM dba_users WHERE username = 'APP_OWNER';
```

## Create a tablespace (filesystem)

```sql
CREATE TABLESPACE training DATAFILE '/u01/oradata/training_01.dbf' SIZE 10M;

CREATE TABLESPACE training_9 DATAFILE '/u01/oradata/training_9.dbf'
  SIZE 10M AUTOEXTEND ON NEXT 10M MAXSIZE 2G;
```

* In `DBA_DATA_FILES`: `AUTOEXTENSIBLE` = yes/no, `MAXBYTES` = the max TBS size, `INCREMENT_BY` = the extension value.
* For `AUTOEXTEND`, don't pick too-small a value — there can be a limit on the number of extends.

```sql
CREATE TABLESPACE ora_data
  DATAFILE 'g:\oracle\oradata\orcl\ORA_DATA01.dbf' SIZE 100M,
           'g:\oracle\oradata\orcl\ORA_DATA02.dbf' SIZE 100M
  MINIMUM EXTENT 500K              -- V8 only
  DEFAULT STORAGE (initial 500K next 500K MAXEXTENTS 500 PCTINCREASE 0);
```

## Create a tablespace (ASM)

```sql
CREATE TABLESPACE "MYDATA" LOGGING
  DATAFILE '+DATA/ORCL/MYDATA01.dbf' SIZE 100M REUSE
  AUTOEXTEND ON NEXT 20M MAXSIZE 22G
  EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE DATA_TBS
  DATAFILE '+DATA' SIZE 100M AUTOEXTEND ON, '+DATA' SIZE 100M AUTOEXTEND ON;
-- grows to 32G by default (can be changed).

CREATE TABLESPACE DATA_CFRM DATAFILE '+DATA' SIZE 100M AUTOEXTEND ON MAXSIZE 10G;
CREATE TABLESPACE TEMPTABS  DATAFILE '+DATA' SIZE 100M AUTOEXTEND ON MAXSIZE 10G;
```

Change the maxsize:

```sql
ALTER DATABASE DATAFILE '+DATA/ORCL/MYDATA.dbf'  AUTOEXTEND ON MAXSIZE 31G;
ALTER DATABASE DATAFILE '+DATA/ORCL/MYINDX.dbf'  AUTOEXTEND ON MAXSIZE 22G;
```

## Creation & storage parameters

Creation parameters:

* `DATAFILE` — list of datafiles.
* `MINIMUM EXTENT` — every extent size is a multiple of this integer.
* `ONLINE` / `OFFLINE` — available immediately or not.
* `PERMANENT` / `TEMPORARY` — permanent or temporary objects.
* `DEFAULT STORAGE` — storage for all objects in the tablespace.

`DEFAULT STORAGE` parameters:

* `INITIAL` — size of the first extent (default 5 × `DB_BLOCK_SIZE`).
* `NEXT` — size of the next extent.
* `MINEXTENTS` — extents allocated at segment creation (default 1).
* `PCTINCREASE` — growth percentage: the n-th next = `next * (1 + pctincrease/100)^(n-2)`. E.g. initial 16k, pctincrease 10 → extents 16k, 16k, 18k, 20k, …

## Add / resize / drop datafiles

```sql
ALTER TABLESPACE training ADD DATAFILE '/u01/oradata/training_02.dbf' SIZE 10M;
ALTER DATABASE DATAFILE '/u01/oradata/training_01.dbf' RESIZE 20M;

ALTER TABLESPACE MYDATA ADD DATAFILE '+DATA/ORCL/MYDATA02.dbf' SIZE 100M REUSE AUTOEXTEND ON NEXT 20M;
ALTER TABLESPACE MYDATA DROP DATAFILE '+DATA/ORCL/mydata.dbf';
```

{{< bs/alert warning >}}
When a tablespace has allocated extents, they remain allocated even if rows are deleted — so a tablespace filled to 80% cannot be shrunk by more than 20%. Only `TRUNCATE TABLE` or `ALTER INDEX REBUILD` releases extents; to retrim you may have to move the objects to another tablespace first.
{{< /bs/alert >}}

## DBF & blocks

A `.dbf` is divided into segments and blocks (the minimum unit). You choose the block size (2k / 4k / 8k / 16k / 32k) — e.g. for images, 32k blocks reduce I/O.

## Temporary tablespace

```sql
CREATE TEMPORARY TABLESPACE temp_training TEMPFILE '/u01/oradata/training_temp_1.dbf' SIZE 10M;
ALTER TABLESPACE temp_training ADD TEMPFILE '/u01/oradata/training_temp_2.dbf' SIZE 10M;
ALTER DATABASE TEMPFILE '/u01/oradata/training_temp_1.dbf' RESIZE 20M;
```

```sql
CREATE USER my_user IDENTIFIED BY my_password
  DEFAULT TABLESPACE training TEMPORARY TABLESPACE temp_training;
```

### Check the space of the TEMP tablespace

```sql
COL file_name FOR a60;
SELECT tablespace_name, file_name, status, increment_by FROM dba_temp_files;

SELECT file_name, bytes/1024/1024/1024, maxbytes/1024/1024/1024 FROM dba_temp_files;
```

```sql
SELECT tablespace_name, tablespace_size/1024/1024 AS "TABLESPACE_SIZE",
       free_space/1024/1024 AS "FREE_SPACE"
FROM dba_temp_free_space;
```

### Reclaim space on TEMP

```sql
-- ⚠️ careful — only when nothing is using it:
ALTER TABLESPACE TEMP SHRINK TEMPFILE '+DATA/ORCL/temp01.dbf' KEEP 1G;
ALTER TABLESPACE TEMP SHRINK TEMPFILE '/u01/oracle/base/oradata/ORCL/temp01.dbf' KEEP 1G;
```

## Move a tablespace

1. Take it OFFLINE: `ALTER TABLESPACE ora_data OFFLINE;`
2. Copy the `.dbf` to the new directory.
3. Rename: `ALTER DATABASE RENAME FILE 'g:\...\ORA_DATA01.dbf' TO 'g:\...\data\ORA_DATA01.dbf';`
4. Bring it ONLINE: `ALTER TABLESPACE ora_data ONLINE;`
5. Delete the old file.

## Read-only / drop

```sql
ALTER TABLESPACE app_data READ ONLY;      -- read-only.
ALTER TABLESPACE app_data READ WRITE;     -- read/write.

DROP TABLESPACE app_data INCLUDING CONTENTS;   -- drop a tablespace.
DROP TABLESPACE DATA_TBS INCLUDING CONTENTS AND DATAFILES;
```

{{< bs/alert warning >}}
`DROP TABLESPACE` does not delete the datafile; remove the file manually if needed (or use `… INCLUDING CONTENTS AND DATAFILES`).
{{< /bs/alert >}}

## Reclaim space (HWM)

Reclaims space on the filesystem/ASM when the tablespace is AUTOEXTEND:

{{< code-snippet "oracle/reclaim_space.sql" "sql" >}}

## Database size

```sql
SELECT TRUNC(SUM(bytes)/1024/1024/1024) AS "DB_SIZE_GB" FROM dba_data_files;   -- total (no temp).

SELECT ROUND(SUM(bytes)/1024/1024/1024) AS "Used GB" FROM dba_segments;        -- used (no temp).
SELECT ROUND(SUM(bytes)/1024/1024/1024) AS "Free GB" FROM dba_free_space;      -- free (no temp).
-- used + free = total.
```

Space used per schema in a tablespace:

```sql
SELECT owner, TO_CHAR(SUM(bytes)/1024/1024/1024, '990.00') AS gb
FROM dba_segments WHERE tablespace_name = 'DATA_TBS' GROUP BY owner;
```

Space used per user (all tablespaces):

```sql
SELECT owner, 'Used: ' || TO_CHAR(SUM(bytes)/1024/1024, '99990.00') || ' (Mo)'
FROM dba_segments GROUP BY owner;
```

## Table sizes

Backup a table:

```sql
CREATE TABLE app_log_table_bak AS SELECT * FROM app_log_table;
```

List the tables of a schema:

```sql
SELECT DISTINCT owner, object_name FROM dba_objects WHERE object_type = 'TABLE' AND owner = 'APP_OWNER';
```

What takes space (per segment type):

```sql
SELECT segment_type, SUM(bytes)/(1024*1024*1024) gb
FROM dba_segments WHERE owner = 'APP_USER' GROUP BY segment_type ORDER BY 2 DESC;
```

Find the biggest table per tablespace:

```sql
SELECT tablespace_name, segment_name, tab_size_mb FROM (
  SELECT tablespace_name, segment_name, bytes/1024/1024 tab_size_mb,
         RANK() OVER (PARTITION BY tablespace_name ORDER BY bytes DESC) AS rnk
  FROM dba_segments WHERE segment_type = 'TABLE'
) WHERE rnk = 1;
```

Size of every table (with its indexes and LOBs) in a schema:

```sql
SET LINES 200 PAGES 2000
COLUMN size_mb    FORMAT '999,999,990.0'
COLUMN num_rows   FORMAT '999,999,990'
COLUMN owner      FORMAT A16
SELECT lower(owner) AS owner, lower(table_name) AS table_name, tablespace_name,
       num_rows, blocks*8/1024 AS size_mb, pct_free, compression, logging
FROM all_tables
WHERE owner LIKE UPPER('&1') OR owner = USER
ORDER BY 1,2;
```

## Recycle bin

Disable the recycle bin:

```sql
ALTER SYSTEM SET recyclebin = OFF SCOPE=SPFILE;
-- or, on versions without the RECYCLEBIN parameter:
ALTER SYSTEM SET "_recyclebin" = FALSE SCOPE=BOTH;
-- on RAC, disable it on every instance.
PURGE DBA_RECYCLEBIN;
```

Check & list:

```sql
SHOW PARAMETER recyclebin;
SHOW RECYCLEBIN;
```
## Schemas & owners

* An **owner** is a **schema** — a user that owns database objects.
* Unlike "one file per database", Oracle stores the objects of the schemas inside tablespaces.

```sql
SELECT SUM(bytes), owner FROM dba_segments GROUP BY owner;   -- owners = the schemas on the instance.
SELECT DISTINCT owner, tablespace_name FROM dba_segments;    -- one schema can span several tablespaces.
SELECT username, default_tablespace, temporary_tablespace FROM dba_users;   -- defaults live in dba_users.
```

## Oracle Managed Files (OMF)

OMF lets Oracle auto-create and name datafiles, tempfiles, redo logs and control files, so you no longer specify paths in `CREATE TABLESPACE`.

```sql
SHOW PARAMETER db_creat;
```

```sql
ALTER SYSTEM SET db_create_file_dest = '+DATA' SCOPE = BOTH;   -- datafiles / tempfiles / controlfiles.
```

* `db_create_file_dest` — default location for datafiles, tempfiles and the default control file.
* `db_create_online_log_dest_1..5` — locations for the redo logs (multiplexed).
* `db_recovery_file_dest` — the Fast Recovery Area (FRA) for RMAN backups and archived logs.

```sql
SHOW PARAMETER reco;
-- control_file_record_keep_time, db_recovery_file_dest, db_recovery_file_dest_size ...
```

With OMF enabled, `CREATE TABLESPACE t DATAFILE SIZE 100M;` (no path) places the file automatically.
