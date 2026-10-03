---
date: 2024-08-03T21:00:00+08:00
title: 💾 Backup & Recovery (RMAN)
nav_weight: 90 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Databases
  - Storage
---

## Connect

```bash
rman
RMAN> connect target
```

```bash
rman target /
```

With a recovery catalog:

```bash
rman target sys/<pwd>@orcl catalog repo/<pwd>@rmancat
```

```sql
RMAN> CONFIGURE CONTROLFILE AUTOBACKUP ON;   -- enables restoring the CONTROLFILE.
RMAN> SHOW ALL;                              -- the whole RMAN configuration.
```

## Backup

```sql
RMAN> BACKUP DATABASE;                                    -- full backup.
RMAN> BACKUP DATABASE PLUS ARCHIVELOG;                    -- full + archived logs.
RMAN> BACKUP INCREMENTAL LEVEL 0 DATABASE;                -- level 0 = baseline.
RMAN> BACKUP INCREMENTAL LEVEL 1 DATABASE;                -- level 1 = incremental.
RMAN> BACKUP CUMULATIVE INCREMENTAL LEVEL 1 DATABASE;     -- cumulative increments.
RMAN> BACKUP AS COMPRESSED BACKUPSET DATABASE;            -- compressed full backup.
RMAN> BACKUP ARCHIVELOG UNTIL TIME 'sysdate - 1/24' ALL DELETE INPUT;
```

Run a script:

```bash
rman cmdfile rman_backup_orcl_arc_20200330.rcv
```

A full-backup `run {}` block:

{{< code-snippet "oracle/rman_full_backup.rcv" "text" >}}

## Verify

```sql
RMAN> LIST BACKUP;
RMAN> CROSSCHECK BACKUP;            -- are the backups where they should be?
RMAN> DELETE EXPIRED BACKUP;        -- delete backups whose media went missing.
RMAN> BACKUP VALIDATE DATABASE;     -- simulate a backup.
RMAN> RESTORE VALIDATE DATABASE;    -- simulate a restore.
```

## Retention policy

* **Redundancy** (e.g. 3): every full/incremental older than 3 backups is obsolete.
* **Recovery window** (e.g. 1 month): everything older than the window is obsolete.

```sql
RMAN> CONFIGURE RETENTION POLICY TO REDUNDANCY 1;
RMAN> CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 3 DAYS;
RMAN> REPORT OBSOLETE;
RMAN> DELETE NOPROMPT OBSOLETE;
```

## Cleanup

```sql
-- all archived logs older than 7 days
RMAN> DELETE NOPROMPT BACKUP COMPLETED BEFORE 'sysdate-7';

RMAN> RUN {
  CROSSCHECK ARCHIVELOG ALL;
  CROSSCHECK BACKUP;
  DELETE NOPROMPT OBSOLETE;
  DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;
  DELETE NOPROMPT EXPIRED BACKUP;
}
```

Re-catalog files that RMAN no longer detects:

```sql
RMAN> CATALOG START WITH '+FRA/MYDB';
```

## Restore

### To a point in time (SCN or date)

```sql
RUN {
  SHUTDOWN IMMEDIATE;
  STARTUP MOUNT;
  SET UNTIL SCN 527478;     -- the SCN just before the action to undo.
  RESTORE DATABASE;
  RECOVER DATABASE;
}
```

```sql
RUN {
  SHUTDOWN IMMEDIATE;
  STARTUP MOUNT;
  SET UNTIL TIME "TO_DATE('28-07-2020:14:00:04','DD-MM-YYYY:hh24:mi:ss')";
  RESTORE DATABASE;
  RECOVER DATABASE;
}
ALTER DATABASE OPEN RESETLOGS;
```

### Restore a datafile (or the whole database)

```sql
RMAN> RESTORE DATAFILE 1;
RMAN> RECOVER DATAFILE 1;
RMAN> ALTER DATABASE OPEN;

RMAN> RESTORE DATABASE;
RMAN> RECOVER DATABASE;
RMAN> ALTER DATABASE OPEN;
```

The recommended 3-step flow (order matters):

```sql
RMAN> LIST FAILURE;
RMAN> ADVISE FAILURE;
RMAN> REPAIR FAILURE;
```

Run several commands together:

```sql
RMAN> RUN {
  RESTORE DATABASE;
  RECOVER DATABASE;
  ALTER DATABASE OPEN;
}
```

### Lost CONTROLFILE

```sql
RMAN> RESTORE CONTROLFILE FROM AUTOBACKUP;
RMAN> ALTER DATABASE OPEN RESETLOGS;    -- new incarnation.
RMAN> BACKUP DATABASE;
RMAN> CATALOG START WITH '/backup/';
```

### Restore one tablespace

```sql
RMAN> RUN {
  ALLOCATE CHANNEL d1 DEVICE TYPE DISK;
  ALLOCATE CHANNEL d2 DEVICE TYPE DISK;
  RESTORE TABLESPACE 'SYSTEM_TBS';
  RECOVER TABLESPACE 'SYSTEM_TBS';
}
```

## Duplicate a database

```sql
RMAN> RUN {
  ALLOCATE CHANNEL d1 DEVICE TYPE DISK;
  ALLOCATE CHANNEL d2 DEVICE TYPE DISK;
  DUPLICATE TARGET DATABASE TO mydb_clone;
}
```

## Catalogue

```sql
RMAN> REPORT SCHEMA;
```

```
Report of database schema for database with db_unique_name ORCL
File Size(MB) Tablespace           RB segs Datafile Name
---- -------- -------------------- ------- ------------------------
1    30108    SYSTEM               YES     +DATA/orcl/datafile/system.260.923225363
2    9048     SYSAUX               NO      +DATA/orcl/datafile/sysaux.261.923225365
...
```

## Troubleshooting

### FRA full (ORA-19804 / ORA-19815)

```sql
grep -i "ORA-" $ORACLE_BASE/diag/rdbms/orcl/ORCL/trace/alert_ORCL.log
-- ORA-19815: WARNING: db_recovery_file_dest_size of ... bytes is 100.00% used
```

Recover space:

```sql
sqlplus / as sysdba
startup mount;
rman target /
RMAN> DELETE OBSOLETE;
-- hardcore:
RMAN> DELETE NOPROMPT ARCHIVELOG ALL;
alter database open;
```

If `+FRA` is exhausted and a redo can't be archived (`ORA-16038`):

```sql
shutdown immediate;
startup mount;
alter database noarchivelog;
alter database clear logfile group 4;
alter database open;

shutdown immediate;
startup mount;
alter database archivelog;
alter database open;
```

### ORA-03113: end-of-file on communication channel

```sql
sqlplus / as sysdba
startup nomount
alter database mount;
alter database clear unarchived logfile group 1;
alter database clear unarchived logfile group 2;
alter database clear unarchived logfile group 3;
shutdown immediate
startup
```

Then check:

```sql
SELECT instance_name, status, database_status FROM v$instance;
```