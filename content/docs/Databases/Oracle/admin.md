---
date: 2024-08-01T21:00:00+08:00
title: 🛠️ Administrations
nav_weight: 20 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Databases
---

## Identify the instance

```bash
echo $ORACLE_SID       # the Oracle instance used before a SQL connection.
echo $ORACLE_HOME      # the Oracle home directory.
```

Load the instance environment:

```bash
. oraenv
```

`/etc/oratab`:

```text
+ASM:/u01/oracle/base/product/12.2.0/grid:N
ORCL:/u01/oracle/base/product/12.2.0/dbhome_1:N
```

All running instances:

```bash
ps -ef | grep pmon
oracle  2201     1  0 12:02 ?  00:00:00 ora_pmon_ORCL
oracle  30513    1  0 Feb12 ?  00:01:11 asm_pmon_+ASM
```

```bash
ps -ef | grep ora_pmon | grep -v grep | awk '{print $NF}' | cut -d"_" -f3
```

### With a Clusterware layer

Check whether an Oracle Clusterware layer is present:

```bash
ps -ef | grep d.bin
# /u01/oracle/base/product/12.2.0/grid/bin/[ohasd|oraagent|evmd|ocssd].bin ...
```

```bash
srvctl config database
```

Listeners and processes:

```bash
ps -edf | grep lsn    # the Oracle listeners on the host.
ps -edf | grep ora    # the Oracle processes.
```

The central inventory (`inventory.xml`):

```xml
<HOME_LIST>
  <HOME NAME="OraGI19Home1" LOC="/u01/oracle/base/product/19.0.0/grid" TYPE="O" IDX="1" CRS="true"/>
  <HOME NAME="OraDB12Home1" LOC="/u01/oracle/base/product/12.2.0/dbhome_1" TYPE="O" IDX="2"/>
</HOME_LIST>
```

## Startup / shutdown

### Shutdown

```sql
SHUTDOWN [parameter];
```

* `NORMAL` (or plain `shutdown;`) — normal shutdown: new connections refused, Oracle waits for all current connections to finish.
* `TRANSACTIONAL` — no new connections; SQL statements in progress run to completion and no new ones are accepted.
* `IMMEDIATE` — users are disconnected; current operations are rolled back.
* `ABORT` — the instance terminates without closing files; an instance recovery is usually required at the next startup.

```sql
SHUTDOWN IMMEDIATE;
```

### Startup

The startup goes through these states:

```text
OFF ──► nomount (SPFILE) ──► mount (CTRLFILE) ──► open
            STARTED              MOUNTED             OPEN
            (SGA + PGA)       (control file read,     (DB operational)
                              files checked, R/O)
```

Step by step:

```sql
STARTUP NOMOUNT;
ALTER DATABASE MOUNT;
ALTER DATABASE OPEN;

ALTER DATABASE CLOSE;
ALTER DATABASE DISMOUNT;
```

Start with a chosen SPFILE:

```sql
STARTUP SPFILE='/path/to/spfile.ora';
```

Check the state (its startup level):

```sql
SELECT status FROM v$instance;                  -- STARTED / MOUNTED / OPEN
SELECT status, database_status, logins FROM v$instance;
```

### STARTUP options

```sql
STARTUP [NOMOUNT | MOUNT | OPEN] [EXCLUSIVE] [PFILE=...] [FORCE] [RESTRICT] [RECOVER];
```

* `NOMOUNT` — creates the SGA and starts the background processes, but gives no access to the database.
* `MOUNT` — mounts the database for DBA activities, but gives no access.
* `OPEN` — users can access the database.
* `EXCLUSIVE` — only the current instance can access the database.
* `PFILE` — use the given init file.
* `FORCE` — aborts the current instance before a normal startup.
* `RESTRICT` — only users with the RESTRICTED SESSION privilege.
* `RECOVER` — starts media recovery at startup.

On Windows, Oracle runs as a service; change the startup script `strt[SID].cmd` in `%ORACLE_HOME%\DATABASE`.

## Memory (SGA / PGA)

```sql
SHOW PARAMETERS pga;
SHOW PARAMETERS sga;
```

```sql
SELECT pool, ROUND(bytes/1024/1024,0) free_mb FROM v$sgastat WHERE name LIKE '%free memory%';

SELECT SUM(bytes/1024/1024) free_mb FROM v$sgastat WHERE name LIKE '%free memory%';

SELECT * FROM v$sga_target_advice ORDER BY sga_size;
```

Resize:

```sql
ALTER SYSTEM SET sga_max_size          = '2352M' SCOPE=SPFILE;
ALTER SYSTEM SET sga_target            = '2352M' SCOPE=SPFILE;
ALTER SYSTEM SET pga_aggregate_limit   = '2G'    SCOPE=SPFILE;
ALTER SYSTEM SET pga_aggregate_target  = '581M'  SCOPE=SPFILE;
```

```sql
CREATE PFILE='/u01/backup/pfile.txt' FROM SPFILE;
SHUTDOWN IMMEDIATE;
STARTUP NOMOUNT;
SHOW PARAMETER sga;
ALTER DATABASE MOUNT;
ALTER DATABASE OPEN;
```

## Logs & ADRCI

### alert.log

```sql
SHOW PARAMETER background_dump_dest;   -- directory containing the alert.log.
```

```bash
ls $ORACLE_BASE/diag/rdbms/*/*/trace/alert*.log
tail -500f $ORACLE_BASE/diag/rdbms/<SID>/<UNIQ_NAME>/trace/alert_<SID>_1.log
```

### ADRCI — the default investigation tool

```bash
$ORACLE_HOME/bin/adrci

adrci> show home
adrci> set home diag/rdbms/orcl/ORCL_1
adrci> show alert -tail 50
adrci> show problem
adrci> show incident -mode basic
adrci> show incident -mode detail -p "incident_id=61553"
adrci> ips create package problem 1 correlate all   # zip to send to Oracle Support.
```

Purge old logs:

```bash
adrci> purge -age 48 -type trace      # 48 hours
adrci> purge -age 2160 -type alert    # 2160 hours = 90 days
# purge -age 2160 -type incident|cdump|stage|sweep|hm
```

```sql
adrci> select SHORTP_POLICY, LONGP_POLICY from ADR_CONTROL;
```

Script to purge every home:

{{< code-snippet "oracle/adrci_purge.sh" "bash" >}}

## Relink after an OS upgrade

As the Oracle user:

```bash
cd $ORACLE_HOME/bin
./relink all
view /u01/oracle/base/product/19c/install/relinkActions*.log
```
## Change MAX_STRING_SIZE to EXTENDED (utl32k.sql)

1. Shut down the database:

```sql
sqlplus / as sysdba
shutdown immediate;
```

(in a RAC ONE NODE environment, prefer `srvctl stop/start -db <db_name>`.)

2. Restart in UPGRADE mode:

```sql
startup upgrade
```

3. Change the setting:

```sql
alter system set max_string_size=EXTENDED scope=both;
```

4. Run `utl32k.sql`:

```bash
cd $ORACLE_HOME/rdbms/admin/
sqlplus / as sysdba
@utl32k.sql
```

5. Shut down:

```sql
shutdown immediate;
```

6. Restart in NORMAL mode:

```sql
startup
```

7. Recompile invalid objects with `utlrp.sql`, connected AS SYSDBA:

```bash
cd $ORACLE_HOME/rdbms/admin/
sqlplus / as sysdba
@utlrp.sql
```

## Oracle version

```sql
SELECT * FROM gv$version;
```

## Undo retention (undo tablespace)

```sql
ALTER TABLESPACE undotbs1 RETENTION GUARANTEE;   -- guarantee the undo retention.
ALTER TABLESPACE undotbs1 RETENTION NOGUARANTEE; -- remove the guarantee.

SHOW PARAMETER undo_retention;   -- the undo retention period in seconds (e.g. 900 s).

ALTER SYSTEM SET undo_retention = 1200;   -- change the retention value.
```

## Perfstat / DBMS_STATS errors

If the alert log shows `ORA-06512` at `DBMS_STATS_*` (an invalidated statistics package):

```bash
grep ORA-06512 $ORACLE_BASE/diag/rdbms/*/*/trace/alert_*.log
```

```sql
EXEC dbms_stats.init_package();
```
