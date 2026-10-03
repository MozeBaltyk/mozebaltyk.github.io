---
date: 2024-08-02T21:00:00+08:00
title: 🚚 Move / Clone a Database
nav_weight: 120 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Databases
---

Copy the source database `oraprd` into a target test database `oratest` (created beforehand). The copy stops `oratest` and replaces its files with `oraprd`'s, then makes them take effect.

## 1. Generate the control-file script

```sql
ALTER DATABASE BACKUP CONTROLFILE TO TRACE;
```

This writes a trace file into `user_dump_dest`. The relevant part looks like:

```sql
STARTUP NOMOUNT
CREATE CONTROLFILE REUSE DATABASE "oraprd" NORESETLOGS ARCHIVELOG
MAXLOGFILES 5
MAXLOGMEMBERS 3
MAXDATAFILES 100
MAXINSTANCES 1
MAXLOGHISTORY 908
LOGFILE
  GROUP 1 'G:\ORACLE\ORADATA\oraprd\REDO01.LOG' SIZE 10M,
  GROUP 1 'G:\ORACLE\ORADATA\oraprd\REDO02.LOG' SIZE 10M,
  GROUP 2 'F:\ORACLE\ORADATA\oraprd\REDO03.LOG' SIZE 10M,
  GROUP 2 'F:\ORACLE\ORADATA\oraprd\REDO04.LOG' SIZE 10M
DATAFILE
  'F:\ORACLE\ORADATA\oraprd\SYSTEM01.DBF',
  'F:\ORACLE\ORADATA\oraprd\CWMLITE01.DBF',
  'F:\ORACLE\ORADATA\oraprd\DATA\DATPRD.DBF',
  ... (the whole list of datafiles)
CHARACTER SET WE8MSWIN1252
;

RECOVER DATABASE
ALTER SYSTEM ARCHIVE LOG ALL;
ALTER DATABASE OPEN;
ALTER TABLESPACE TEMP ADD TEMPFILE 'G:\ORACLE\ORADATA\oraprd\TEMP02.DBF' SIZE 2000M REUSE AUTOEXTEND OFF;
```

## 2. Adapt the generated script

{{< bs/alert warning >}}
The source database must be shut down so that all files are synchronized.
{{< /bs/alert >}}

Once `oraprd`'s files are copied over `oratest`, adapt the control-file script to the new paths (e.g. `F:\ORACLE\ORADATA\oraprd` and `G:\...` → `D:\ORACLE\ORADATA\oratest`), and change the database name:

```sql
-- CREATE CONTROLFILE REUSE DATABASE "oraprd" NORESETLOGS ARCHIVELOG
-- becomes
CREATE CONTROLFILE SET DATABASE "oratest" RESETLOGS ARCHIVELOG
```

Comment the `RECOVER DATABASE;` line (the source was shut down cleanly, no recovery needed), and open with `RESETLOGS`:

```sql
-- ALTER DATABASE OPEN;  becomes
ALTER DATABASE OPEN RESETLOGS;
```

Final script (shortened):

```sql
STARTUP NOMOUNT
CREATE CONTROLFILE SET DATABASE "oratest" RESETLOGS ARCHIVELOG
MAXLOGFILES 5
MAXLOGMEMBERS 3
MAXDATAFILES 100
MAXINSTANCES 1
MAXLOGHISTORY 908
LOGFILE
  GROUP 1 'D:\ORACLE\ORADATA\oratest\REDO01.LOG' SIZE 10M,
  GROUP 1 'D:\ORACLE\ORADATA\oratest\REDO02.LOG' SIZE 10M,
  GROUP 2 'D:\ORACLE\ORADATA\oratest\REDO03.LOG' SIZE 10M,
  GROUP 2 'D:\ORACLE\ORADATA\oratest\REDO04.LOG' SIZE 10M
DATAFILE
  'D:\ORACLE\ORADATA\oratest\SYSTEM01.DBF',
  'D:\ORACLE\ORADATA\oratest\DATA\DATPRD.DBF',
  ... (the same list, adapted to the new paths)
CHARACTER SET WE8MSWIN1252
;

ALTER DATABASE OPEN RESETLOGS;
ALTER TABLESPACE TEMP ADD TEMPFILE 'D:\ORACLE\ORADATA\oratest\TEMP02.DBF' SIZE 2000M REUSE AUTOEXTEND OFF;
```

Finally, if the init file was also copied, rename `initORAPRD.ora` → `initORATEST.ora` and update: `db_name`, `control_files`, `user_dump_dest`, `background_dump_dest`, `core_dump_dest`, `utl_file_dir`. Also shrink the database and disable ARCHIVELOG if not needed.

## 3. Restart the database

Connect AS SYSDBA and run the script:

```bash
sqlplus "/ as sysdba"
SQL> @control_file_oratest.sql
SQL> shutdown immediate
SQL> startup
```

On Windows (as a service):

```bash
net start OracleServiceoratest
sqlplus "/ as sysdba"
SQL> @control_file_oratest.sql
SQL> shutdown immediate
SQL> startup
```

It takes ~30 minutes (excluding the file copy); check `alert_oratest.log` to confirm everything is operational.