---
date: 2024-08-02T21:00:00+08:00
title: ⚙️ SPFILE & PFILE
nav_weight: 30 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Databases
---

## Configuration via init.ora (PFILE)

`init.<SID>.ora` was the way to configure Oracle 8/9. It is the database parameter file — without it the database cannot start. Default location: `$ORACLE_HOME/dbs` (UNIX) or `%ORACLE_HOME%\database` (Windows).

{{< bs/alert warning >}}
Sometimes a system stays on `init.<SID>.ora` even on 11g/12c, because the instance was upgraded from an old version.
{{< /bs/alert >}}

Examples of parameters:

* `BACKGROUND_DUMP_DEST` — where the background-process trace files are written.
* `USER_DUMP_DEST` — where the user trace files are created.
* `COMPATIBLE` — the server version the instance is compatible with.
* `CONTROL_FILES` — the control file names.
* `DB_BLOCK_BUFFERS` — number of blocks cached in the SGA (default/minimum 50).
* `DB_NAME` — database identifier (5 chars or fewer; the only parameter required to create a database).
* `SHARED_POOL_SIZE` — shared pool size in bytes (default 3 500 000).
* `IFILE` — reference another parameter file to nest.
* `LOG_BUFFER` — bytes allocated to the redo log buffer.
* `MAX_DUMP_FILE_SIZE` — max trace file size (in OS blocks).
* `PROCESSES` — number of OS processes that can connect simultaneously.
* `SQL_TRACE` — enable/disable SQL tracing per session (see TKPROF).
* `TIMED_STATISTICS` — enable/disable timing in traces and on screens.

## Configuration via SPFILE

The SPFILE arrived with 9i. To change it, convert the SPFILE to a text PFILE, edit, then convert back to a binary SPFILE.

```sql
COL name  FOR a30
COL value FOR a30
SELECT name, value FROM v$parameter;
```

```sql
SHOW PARAMETER spfile;      -- version & location of the SPFILE.
SHOW PARAMETER processes;
SHOW PARAMETER sessions;
SHOW PARAMETER open_cursors;
```

### Convert

```sql
CREATE PFILE='/u01/app/oracle/pfile.txt' FROM SPFILE;       -- minimal params needed to start.
CREATE SPFILE FROM PFILE='/u01/app/oracle/pfile.txt';       -- (restart to take effect)
CREATE PFILE='/u01/app/oracle/pfile_full.txt' FROM MEMORY;  -- also includes all Oracle defaults.
```

### Modify a parameter

```sql
ALTER SYSTEM SET open_cursors = 300;              -- on the fly (not possible for every param).
ALTER SYSTEM SET sessions = 300 SCOPE=SPFILE;     -- write to the SPFILE (needs a restart).
ALTER SYSTEM SET processes = 300 SCOPE=BOTH;      -- SPFILE + memory (not valid for SESSIONS).
```

## SPFILE location

* UNIX: `$ORACLE_HOME/dbs/init$ORACLE_SID.ora`
* Windows: `%ORACLE_HOME%\database\init<SID>.ora`