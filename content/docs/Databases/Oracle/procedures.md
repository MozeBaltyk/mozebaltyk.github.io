---
date: 2024-08-01T21:00:00+08:00
title: Procedures
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - DBA
categories:
  - Docs
tags:
  - Oracle
---

## Basics 

* find a procedures 

```sql
SELECT *
  FROM USER_OBJECTS
 WHERE object_type = 'PROCEDURE'
   AND object_name = 'grant_RW'
```

* Example which give `SELECT` right on one schema to the role

```sql
CREATE OR REPLACE PROCEDURE grant_RO_to_schema(
    username VARCHAR2,
    grantee VARCHAR2)
AS
BEGIN
    FOR r IN (
        SELECT owner, table_name
        FROM all_tables
        WHERE owner = username
    )
    LOOP
        EXECUTE IMMEDIATE
            'GRANT SELECT ON '||r.owner||'.'||r.table_name||' to ' || grantee;
    END LOOP;
END;
/

-- See if procedure is ok -- 
SHOW ERRORS 

CREATE ROLE '${ROLE_NAME}' NOT IDENTIFIED;
GRANT CONNECT TO '${ROLE_NAME}';
GRANT SELECT ANY SEQUENCE TO '${ROLE_NAME}';
GRANT CREATE ANY TABLE TO '${ROLE_NAME}';

-- Play the Procedure -- 
EXEC grant_RO_to_schema('${SCHEMA}','${ROLE_NAME}')
```

* Procedure which give Read/Write right to one schema:

```bash
su - oracle -c '
export SQLPLUS="sqlplus -S / as sysdba"
export ORAENV_ASK=NO;
export ORACLE_SID='${SID}';
. oraenv | grep -v "remains";

${SQLPLUS} <<EOF2
set lines 200 pages 2000;
CREATE OR REPLACE PROCEDURE grant_RW_to_schema(
    username VARCHAR2,
    grantee VARCHAR2)
AS
BEGIN
    FOR r IN (
        SELECT owner, table_name
        FROM all_tables
        WHERE owner = username
    )
    LOOP
        EXECUTE IMMEDIATE
            '\''GRANT SELECT,DELETE,UPDATE,INSERT,ALTER ON '\''||r.owner||'\''.'\''||r.table_name||'\'' to '\'' || grantee;
    END LOOP;
END;
/
CREATE ROLE '${ROLE_NAME}' NOT IDENTIFIED;
GRANT CONNECT TO '${ROLE_NAME}';
GRANT SELECT ANY SEQUENCE TO '${ROLE_NAME}';
GRANT CREATE ANY TABLE TO '${ROLE_NAME}';
GRANT CREATE ANY INDEX TO '${ROLE_NAME}';
EXEC grant_RW_to_schema('\'''${SCHEMA}''\'','\'''${ROLE_NAME}''\'')
exit;
EOF2
unset ORAENV_ASK;
'
```

```sql
-- This one is working better : 
CREATE OR REPLACE PROCEDURE grant_RW_to_schema(
myschema VARCHAR2,
myrole VARCHAR2)
AS
BEGIN
for t in (select owner,object_name,object_type from all_objects where owner=myschema and object_type in ('TABLE','VIEW','PROCEDURE','FUNCTION','PACKAGE')) loop
if t.object_type in ('TABLE','VIEW') then
EXECUTE immediate 'GRANT SELECT, UPDATE, INSERT, DELETE ON '||t.owner||'.'||t.object_name||' TO '|| myrole;
elsif t.object_type in ('PROCEDURE','FUNCTION','PACKAGE') then
EXECUTE immediate 'GRANT EXECUTE ON '||t.owner||'.'||t.object_name||' TO '|| myrole;
end if;
end loop;
end;
/
```