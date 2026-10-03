---
date: 2024-08-01T21:00:00+08:00
title: 👥 Users, Roles & Privileges
nav_weight: 130 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Databases
---

## Managing users

Four main concepts:

* **USERS** — with the granted **PRIVILEGES**.
* **ROLES** — a pack of privileges.
* **PROFILES** — a pack of limitations.

> Note: an unquoted SQL name is uppercase; a quoted name keeps its case as written.

Creation / deletion:

```sql
-- all users, with account status, expiry, profile, etc.
SELECT username, profile, account_status, expiry_date, lock_date
FROM dba_users WHERE oracle_maintained = 'N';

CREATE USER my_user IDENTIFIED BY my_password;   -- create a user.
DROP USER my_user;                              -- drop a user.
DROP USER my_user CASCADE;                      -- drop a user and all its tables.
```

## Privileges

```sql
SELECT * FROM dba_sys_privs;                               -- all possible privileges.
SELECT * FROM dba_sys_privs WHERE grantee = 'MY_USER';     -- one user's privileges.

GRANT create session, alter session, drop any index TO my_user;
REVOKE alter session FROM my_user;
```

## Roles

```sql
CREATE ROLE my_role;      -- create a role.
GRANT create session, alter session, drop tablespace, delete any table TO my_role;  -- grant to a role.
GRANT my_role TO my_user, hr;   -- grant a role to users.
REVOKE alter session FROM my_role;

SELECT * FROM dba_roles;
SELECT * FROM dba_role_privs WHERE grantee = 'MY_USER';   -- roles of one user.
SELECT grantee, granted_role, admin_option, default_role FROM dba_role_privs ORDER BY 1,2;
SELECT * FROM dba_sys_privs WHERE grantee = 'MY_ROLE';
SELECT * FROM dba_tab_privs WHERE grantee = 'MY_ROLE';
```

## Profiles

```sql
SELECT * FROM dba_profiles;                              -- all profiles.
SELECT * FROM dba_profiles WHERE profile = 'MY_PROFILE'; -- one profile's limits.

CREATE PROFILE my_profile LIMIT idle_time 15 connect_time 20 failed_login_attempts 50;
ALTER USER my_user PROFILE my_profile;
```

## Account management

```sql
ALTER USER my_user IDENTIFIED BY new_password;   -- change the password.
ALTER USER my_user ACCOUNT UNLOCK;               -- unlock a user.
```

## sys / system

```sql
ALTER USER sys IDENTIFIED BY '<password>';
ALTER USER system IDENTIFIED BY '<password>';
```

> If the DB password is changed, you must also regenerate the password file (`orapwd`), which controls remote `SYSDBA` access:

```bash
cd $ORACLE_HOME/dbs
orapwd file=orapwORCL password=<password> format=12 force=y
```

`remote_login_passwordfile`:

```sql
SHOW PARAMETER remote_login_passwordfile;   -- NONE (no remote sysdba) / EXCLUSIVE
```

Test the network connection:

```bash
vi $ORACLE_HOME/network/admin/tnsnames.ora
sqlplus sys@orcl as sysdba
```

Block access for the application:

```sql
ALTER SYSTEM ENABLE RESTRICTED SESSION;
ALTER SYSTEM DISABLE RESTRICTED SESSION;
```

## Sessions & locking

```sql
-- Sessions and their current status
SELECT sid, serial#, username, status, event FROM v$session WHERE type = 'USER';
```

```sql
-- Which object is locked, by which session (lmode/request = lock mode)
SELECT o.object_name, lo.session_id, lo.type, lo.lmode, lo.request
FROM v$locked_object lo JOIN dba_objects o ON lo.object_id = o.object_id;
```

## Hierarchical: user → roles → privileges

```sql
SELECT lpad(' ', 2*level) || granted_role "User, roles and privileges"
FROM (
  SELECT NULL grantee, username granted_role FROM dba_users WHERE username = 'MY_USER'
  UNION
  SELECT grantee, granted_role FROM dba_role_privs
  UNION
  SELECT grantee, privilege FROM dba_sys_privs
)
START WITH grantee IS NULL
CONNECT BY grantee = PRIOR granted_role;
```