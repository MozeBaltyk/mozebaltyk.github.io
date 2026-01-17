---
date: 2024-08-01T21:00:00+08:00
title: Oracle Clients
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - DBA
tags:
  - Oracle
  - Admin
---

## Listener / Tnsname.ora

```bash
# Check if listner is present
ps -edf | grep lsn

# Prompt Listner
lsnrctl
LSNRCTL> help
The following operations are available
An asterisk (*) denotes a modifier or extended command:

start           stop            status          services
version         reload          save_config     trace
spawn           quit            exit            set*
show*

lsnrctl status
lsnrctl start

# Logs
less /opt/oracle/product/12c/db/network/admin/listener.ora
```

## Local Listner

```shell
# in Oracle prompt
show parameter listener;
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
listener_networks                    string
local_listener                       string      LISTENER_TOTO
remote_listener                      string
```

* First  LISTENER_TOTO must be defined in the `tnsnames.ora`.

```shell
# in Oracle prompt
alter system set local_listener='LISTENER_TOTO' scope=both;
alter system register;
```

```shell
lsnrctl status

LSNRCTL for Linux: Version 12.2.0.1.0 - Production on 29-APR-2021 18:58:48
Copyright (c) 1991, 2016, Oracle.  All rights reserved.
Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 12.2.0.1.0 - Production
Start Date                29-APR-2021 18:11:13
Uptime                    0 days 0 hr. 47 min. 34 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Log File         /u01/oracle/base/diag/tnslsnr/myhost/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=myhost.example.com)(PORT=1521)))
Services Summary...
Service "+ASM" has 1 instance(s).
  Instance "+ASM", status READY, has 1 handler(s) for this service...
Service "+ASM_DATA" has 1 instance(s).
  Instance "+ASM", status READY, has 1 handler(s) for this service...
Service "+ASM_FRA" has 1 instance(s).
  Instance "+ASM", status READY, has 1 handler(s) for this service...
Service "IANA" has 1 instance(s).
  Instance "IANA", status READY, has 1 handler(s) for this service...
Service "IANAXDB" has 1 instance(s).
  Instance "IANA", status READY, has 1 handler(s) for this service...
The command completed successfully
```

## Static Listner: TNSnames.ORA

Services have to be listed in `tnsnames.ora` of client hosts.

by default: `$ORACLE_HOME/network/admin/.` change take effect after listner restart.

* Example of `tnsnames.ora` used by `client SQLplus` and `TNSping`:

```shell
XE =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = shigerum-pc)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = XE)
    )
  )
```

* An other with service name:

```shell
# vi ${ORACLE_HOME}/network/admin/tnsnames.ora
# vi ${ORACLE_HOME}/client/network/admin/tnsnames.ora
LOCAL =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL= TCP)(Host= 10.0.0.3)(Port= 1521))
    (CONNECT_DATA = (SID = REMOTE))
  )

# then connect with:
sqlplus user/password@LOCAL
```

## [Debug] TNSping

* After defining on app server `tnsnames.ora` and make sure network is open:

```shell
# tnsping <service_name> <count> 
$ tnsping GRACELANV8_GRA901m 5

TNS Ping Utility for Solaris: Version 9.2.0.1.0 - Production on 03-JAN-2003 14:47:09

Copyright (c) 1997 Oracle Corporation. All rights reserved.

Used parameter files:
/usr/oracle/9.2.0/network/admin/sqlnet.ora

Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION= (ADDRESS= (PROTOCOL=TCP) (HOST=gracelan)
(PORT=1525)) (CONNECT_DATA= (SID=GRA901m)))
OK (80 msec)
OK (10 msec)
OK (10 msec)
OK (0 msec)
OK (10 msec)
```

NB - first result longer since:
- read alias GRACELANV8_GRA901m from tnsnames.ora
- resolv dns
- connect 
- second 10ms since all cache

## SQLplus Connexion

* Connect as root (sysdba) in local

```shell
su - oracle
sqlplus <Login>/<pwd> as sysdba
```

* Connect silent mode (avoid banner)

```shell
sqlplus -s / as sysdba
```

* Connect local specific db

```shell
# sid correspond to a $ORACLE_SID
sqlplus user/password@sid
sqlplus 'system/PWD'@sid as sysdba
```

* Connect to distante db

```shell
sqlplus user/password@'(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=10.0.0.2)(PORT=1521)))(CONNECT_DATA=(SID=REMOTE)))'

# Service defined in tnsnames.ora (SERVICE_NAME = XE)
sqlplus login/mdp@service
```

## SQLplus scripting

* Execute Script:

```shell
sqlplus username/password@databasename @"c:\my_script.sql"
```

* Execute Command line:

```shell
sqlplus username/password@database < "EXECUTE some_proc /"
```

* Execute Command in multi-lines:

```shell
sqlplus username/password@database <<EOF
EXECUTE some_proc;
EXIT;
EOF
```

* Another example:

```shell
###########
export ORACLE_HOME=/oracleClient/app/oracle/product/version
export DBUSER=fooUser
export DBPASSWD=fooPW
export DBNAME=fooSchema 
echo "select * from someTable;" | $ORACLE_HOME/bin/sqlplus $DBUSER/$DBPASSWD@$DBNAME
```

## Variables in SQLplus

two types:
 - user vars - used in SQL requests and for SQLplus internal usage.

 ```sql
-- # Users vars can be call back with `&my_variable`
DEF[INE] [my_variable = what_inside]

-- # List all vars
DEF 

-- # Delete a var
UNDEF
 ```

 - link variables for PL/SQL commands

```sql
-- # Define a link variable
VAR[IABLE] [nom [NUMBER | CHAR(n)]]

-- # Show content of the var
VARIABLE my_var

-- # Inside sql script can be used with :my_var
```


### Buffer

```sql
sql> LIST   or   L   -- list the last command
sql> RUN    or   /   -- rerun the last command
sql> define_ed=vi    -- then ed command open vi with last command. 
sql> set history on 
sql> history
sql> S[AVE] save_output_in_file {[CREATE]|[REPLACE]|[APPEND]}  // file is create with output of the sql command
```

### Parameters

```sql
SET pagesize 100
SET LINESIZE 300
SET TIMING ON     -- get the request timing  
SET TIME ON       -- get time before command is launch
SET SQLPROMPT "_user on _connect_identifier> "   -- change prompt with user and instance name
SET TRIMSPOOL {ON|OFF}

set lines 200 pages 2000
col COMP_NAME for a60
COLUMN my_research_column FORMAT A25

-- save parameters for next login
<ORACLE_HOME>/sqlplus/admin/glogin.sql
```
