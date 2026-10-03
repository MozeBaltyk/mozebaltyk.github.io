---
date: 2024-08-01T21:00:00+08:00
title: 📦 Export / Import (Data Pump)
nav_weight: 100 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Databases
---

## Export

* `EXP` (legacy): the old export utility — produces a binary dump (superseded by Data Pump).
* `EXPDP` (Data Pump): produces binary dump files, used with `DIRECTORY` objects.

```bash
exp  user/password@host FULL=Y        # full legacy (binary) export.
expdp user/password@host FULL=Y DIRECTORY=DUMP DUMPFILE=full.dmp
```

```bash
# full DB, excluding statistics
nohup expdp 'system/<password>'@orcl FULL=Y DIRECTORY=DUMP \
  DUMPFILE=expdp_orcl_full_$(date +%Y-%m-%d).dmp \
  LOGFILE=expdp_orcl_$(date +%Y-%m-%d).log EXCLUDE=statistics

# one schema
nohup expdp system/<password>@orcl SCHEMAS=my_schema DIRECTORY=DUMP \
  DUMPFILE=my_schema_$(date +%Y-%m-%d)_%U.dmp \
  LOGFILE=my_schema.log EXCLUDE=statistics
```

## Directories & rights

```sql
SET LINES 200 PAGES 2000
SELECT * FROM dba_directories;   -- the paths defined for Oracle.
```

```sql
CREATE DIRECTORY my_dir AS '/backup/dump';
GRANT READ, WRITE ON DIRECTORY my_dir TO my_user;
DROP DIRECTORY my_dir;
```

Then use it in an export: `... DIRECTORY=my_dir DUMPFILE=my_export.dmp`.

## Jobs: stop / resume

```sql
-- see the running jobs
SELECT * FROM dba_datapump_jobs;
```

```bash
expdp attach=<job_name>   # enter the prompt of a running job.
```

```text
IMPORT> status
kill_job         # stop the job.
stop_job         # suspend the job.
start_job        # resume a stopped job.
continue_client  # resume an attached client job.
```

## Import

```bash
# remap a schema
impdp '/ as sysdba' DIRECTORY=DUMP DUMPFILE=my_db_2020-04-01.dmp PARALLEL=1 \
  REMAP_SCHEMA=src_schema:dst_schema

# full import
impdp '/ as sysdba' DIRECTORY=DUMP DUMPFILE=expdp_orcl_2020-09-02.dump \
  LOGFILE=impdp.log PARALLEL=1 FULL=Y

# one schema
impdp '/ as sysdba' DIRECTORY=DUMP DUMPFILE=exp.dmp SCHEMAS=my_schema
```

> Put the `.dmp` file in the DUMP directory (`SELECT * FROM dba_directories;`).

## Cleanup orphaned datapump jobs

```sql
SET HEAD OFF
SELECT 'DROP TABLE ' || owner_name || '.' || job_name || ';'
FROM dba_datapump_jobs WHERE state = 'NOT RUNNING' AND attached_sessions = 0;
```

## Debug & monitor

```bash
tail -500f /u01/oracle/base/diag/rdbms/orcl/ORCL_1/trace/alert_ORCL_1.log
```

Check for waits ("waiting cpu" means the CPU is saturated):

```sql
SELECT DISTINCT event FROM v$session WHERE status = 'ACTIVE';
```

Compare the components of two servers (a difference means a full import may fail):

```sql
SELECT * FROM dba_registry;
```

## Resumable

```sql
SHOW PARAMETER resumable;
ALTER SYSTEM SET resumable_timeout = 7200 SCOPE = BOTH;
```