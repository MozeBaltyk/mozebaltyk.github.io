---
date: 2024-08-03T21:00:00+08:00
title: 🔁 Redo Log & Archivelog
nav_weight: 80 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Databases
  - Storage
---

## Redo log principles

The **redo log files** keep a trace of every data alteration, so that after a crash they can replay the changes. You need at least two, and they deserve careful attention for both backup and access optimisation.

In **ARCHIVELOG** mode the redo logs are archived — keeping a full trace of all changes, not just what fits within the redo log file size. The redo buffer is flushed to disk when it is full, so the redo log files should be at least as large as the redo log buffer (`log_buffer`).

Sizing rules of thumb: a bigger file takes longer to archive, a smaller one archives faster. Aim for ~two archives generated per hour (fewer = less I/O). Spread the files across several disks (ideally a different disk from the database itself) — if the data disks are corrupted and the redo logs are on them, recovery becomes impossible.

## Groups & members

```sql
SELECT groups, current_group#, sequence# FROM v$thread;
SELECT group#, sequence#, bytes, members, status FROM v$log;
SELECT * FROM v$logfile;
```

Redo log `status`:

* `UNUSED` — never written.
* `CURRENT` — online, currently being written.
* `ACTIVE` — online, currently being archived.
* `INACTIVE` — online, archived, not in use.

Force a switch / checkpoint:

```sql
ALTER SYSTEM SWITCH LOGFILE;   -- archive the current group and activate the next.
ALTER SYSTEM CHECKPOINT;       -- archive the current group.
```

### SWITCH LOGFILE vs ARCHIVE LOG CURRENT

Both force a log switch, but work differently:

| | `ALTER SYSTEM SWITCH LOGFILE` | `ALTER SYSTEM ARCHIVE LOG CURRENT` |
|---|---|---|
| Control | returns immediately (does not wait for the archiver) | waits for the archiver to finish |
| How | issues a checkpoint, starts the new group, then archives in background | synchronous — waits for the online redo log to be written |
| RAC | only the local node | all nodes (recommended in RAC) |
| Thread | archives the current thread only | you can specify which thread to archive |
| RMAN | — | the trusted command inside RMAN backups |

## Add / drop groups & members

```sql
ALTER DATABASE ADD LOGFILE GROUP 2 '/u01/oradata/orcl/REDO03.LOG' SIZE 10M;
ALTER DATABASE DROP LOGFILE GROUP 2;
ALTER DATABASE DROP LOGFILE MEMBER '/u01/oradata/orcl/REDO02.LOG';
```

Each redo group usually has two members — one in `+DATA` and one mirrored in `+FRA`:

```sql
ALTER DATABASE ADD LOGFILE GROUP 4 ('+DATA/orcl/redo04a.log', '+FRA/orcl/redo04b.log') SIZE 200M;

SELECT * FROM v$logfile;
-- GROUP#  STATUS  TYPE   MEMBER
-- 4       ONLINE         +DATA/orcl/redo04a.log
-- 4       ONLINE         +FRA/orcl/redo04b.log
```

## Move an online redo log

Scenario: two groups (1 and 2), two members each.

1. Create a temporary group of the redo-log size:

```sql
ALTER DATABASE ADD LOGFILE GROUP 3 '/u01/oradata/orcl/REDO05.LOG' SIZE 10M;
```

2. Switch onto the new group (until it becomes `CURRENT`):

```sql
ALTER SYSTEM SWITCH LOGFILE;
ALTER SYSTEM SWITCH LOGFILE;
```

3. Drop the old members and re-create them in the new directory:

```sql
ALTER DATABASE DROP LOGFILE MEMBER '/u01/oradata/orcl/REDO01.LOG';
ALTER DATABASE ADD LOGFILE GROUP 1 '/u01/oradata/orcl/redo/REDO01.LOG' SIZE 10M;
-- ... repeat per member ...
```

4. Switch through all groups and drop the temporary group:

```sql
ALTER SYSTEM SWITCH LOGFILE;  -- (several times)
ALTER DATABASE DROP LOGFILE GROUP 3;
```

## Archivelog

Activate / deactivate:

```sql
shutdown immediate;
startup mount;
alter database archivelog;      -- or: alter database noarchivelog
alter database open;
```

On a Grid/Clusterware environment:

```bash
srvctl stop database -d MYDB
srvctl start database -d MYDB -o mount
sqlplus / as sysdba
SQL> alter database archivelog;
srvctl stop database -d MYDB
srvctl start database -d MYDB
```

Verify:

```sql
archive log list;
SELECT name, log_mode FROM v$database;
SELECT archiver FROM v$instance;
```

From RMAN:

```bash
rman> connect target
rman> list archivelog all;
```

## Recovery area / FRA configuration

```sql
ALTER SYSTEM SET db_recovery_file_dest      = '+FRA' SCOPE=both sid='*';
ALTER SYSTEM SET db_recovery_file_dest_size = '54G'  SCOPE=both sid='*';
ALTER SYSTEM SET log_archive_dest_1         = 'LOCATION=/orarch/orcl' SCOPE=both sid='*';
```

```sql
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
ALTER SYSTEM SWITCH LOGFILE;   -- force a switch to start archiving.
```

Check the FRA usage:

```sql
COL name FOR A40
SELECT name, CEIL(space_limit/1024/1024) size_m, CEIL(space_used/1024/1024) used_m,
       DECODE(NVL(space_used,0), 0, 0, CEIL((space_used/space_limit)*100)) pct_used
FROM v$recovery_file_dest ORDER BY name;

SELECT * FROM v$recovery_file_dest;
SELECT * FROM v$flash_recovery_area_usage;
```

See the ASM diskgroups (`DATA` / `FRA`):

```bash
. oraenv +ASM1
asmcmd lsdg
```