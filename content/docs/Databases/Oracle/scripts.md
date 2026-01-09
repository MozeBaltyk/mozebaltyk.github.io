---
date: 2024-08-01T21:00:00+08:00
title: Scripting
navWeight: 100 # Upper weight gets higher precedence, optional.
series:
  - DBA
categories:
  - Docs
tags:
  - Oracle
  - Shell
---

## Inside a Shell script

* One line command:

```bash
# Set the SID 
ORAENV_ASK=NO
export ORACLE_SID=HANA
. oraenv

# Trigger oneline command
echo -e "select inst_id, instance_name, host_name, database_status from gv\$instance;" | sqlplus -S / as sysdba
```

* In bash script:

```bash
su - oracle -c '
export SQLPLUS="sqlplus -S / as sysdba"
export ORAENV_ASK=NO;
export ORACLE_SID='${SID}';
. oraenv | grep -v "remains";

${SQLPLUS} <<EOF2
set lines 200 pages 2000;
select inst_id, instance_name, host_name, database_status from gv\$instance;
exit;
EOF2

unset ORAENV_ASK;
'
```

## Inside SQL Prompt

```sql
-- with an absolute path 
@C:\Users\Matthieu\test.sql 

-- or trigger from director on which sqlplus was launched
@test.sql

-- START syntax possible as well
START test.sql  
```

## Variables usages

```sql
-- User variable (if not define, oracle will prompt)
SELECT * FROM &my_table;

-- Prompt user to set a variable
ACCEPT my_table PROMPT "Which table would you like to interrogate ? "
SELECT * FROM $my_table;
```


## Some Examples

* Example of Shell script to launch `sqlplus` command:

```sh
export ORACLE_SID=SQM2DWH3

echo "connect ODS/ODS
BEGIN
ODS.PURGE_ODS.PURGE_LOG();
ODS.PURGE_ODS.PURGE_DATA();
END;
/" | sqlplus /nolog

echo "connect DSA/DSA
BEGIN
DSA.PURGE_DSA.PURGE_LOG();
DSA.PURGE_DSA.PURGE_DATA();
END;
/" | sqlplus /nolog
```

* Example of script to check `tablespaces.sh`

```sh
#!/bin/ksh

sqlplus -s system/manager <<!
SET HEADING off;
SET PAGESIZE 0;
SET TERMOUT OFF;
SET FEEDBACK OFF;
SELECT df.tablespace_name||','||
       df.bytes / (1024 * 1024)||','||
       SUM(fs.bytes) / (1024 * 1024)||','||
       Nvl(Round(SUM(fs.bytes) * 100 / df.bytes),1)||','||
       Round((df.bytes - SUM(fs.bytes)) * 100 / df.bytes)
  FROM dba_free_space fs,
       (SELECT tablespace_name,SUM(bytes) bytes FROM dba_data_files GROUP BY tablespace_name) df
 WHERE fs.tablespace_name (+)  = df.tablespace_name
 GROUP BY df.tablespace_name,df.bytes
 ORDER BY 1 ASC;
quit
!

exit 0
```

```sh
#!/bin/ksh

sqlplus -s system/manager <<!

set pagesize 60 linesize 132 verify off
break on file_id skip 1

column file_id heading "File|Id"
column tablespace_name for a15
column object          for a15
column owner           for a15
column MBytes          for 999,999

select tablespace_name,
'free space' owner, /*"owner" of free space */
' ' object,         /*blank object name */
file_id, /*file id for the extent header*/
block_id, /*block id for the extent header*/
CEIL(blocks*4/1024) MBytes /*length of the extent, in Mega Bytes*/
from dba_free_space
where tablespace_name like '%TEMP%'
union
select tablespace_name,
substr(owner, 1, 20), /*owner name (first 20 chars)*/
substr(segment_name, 1, 32), /*segment name */
file_id, /*file id for extent header */
block_id, /*block id for extent header */
CEIL(blocks*4/1024) MBytes /*length of the extent, in Mega Bytes*/
from dba_extents
where tablespace_name like '%TEMP%'
order by 1, 4, 5
/

quit
!

exit 0
```

## SPOOL to write on system

* from `sqlplus`:
  
```bash
SQL> SET TRIMSPOOL on
SQL> SET LINESIZE 1000
SQL> SPOOL /root/output.txt
SQL> select RULEID as RuleID, RULENAME as ruleName,to_char(DBMS_LOB.SUBSTR(EPLRULESTATEMENT,4000,1() as ruleStmt from gep_rules;
SQL> SPOOL OFF
```

* from `script.sql`:

```sh
SET TRIMSPOOL on
SET LINESIZE 10000
SPOOL resultat.txt
ACCEPT var PROMPT "Which table do you want to get ? "
SELECT * FROM &var;
SPOOL OFF
```

## Generate DATA

* Duplicate table to fill up tablespace or generate fake data:

```bash
SQL> Create table emp as select * from employees; 
SQL> UPDATE emp SET LAST_NAME='ABC';
SQL> commit;
```
