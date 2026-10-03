---
date: 2024-08-04T21:00:00+08:00
title: 🕵️ Auditing
nav_weight: 140 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Databases
---

## Enable auditing

```sql
ALTER SYSTEM SET audit_trail = DB, EXTENDED SCOPE = SPFILE;   -- detailed user actions.
SHOW PARAMETER audit_trail;    -- default NONE → set it to EXTENDED where possible.
SHOW PARAMETER audit;          -- the full audit configuration.
```

## Audit users

```sql
AUDIT SELECT TABLE, UPDATE TABLE, INSERT TABLE BY hr BY SESSION;
AUDIT SELECT TABLE, UPDATE TABLE, INSERT TABLE BY hr BY SESSION WHENEVER SUCCESSFUL;
AUDIT SELECT TABLE, UPDATE TABLE, INSERT TABLE BY hr BY SESSION WHENEVER NOT SUCCESSFUL;
AUDIT SELECT TABLE, UPDATE TABLE, INSERT TABLE BY hr BY ACCESS;
AUDIT SELECT TABLE, UPDATE TABLE, INSERT TABLE BY hr BY ACCESS WHENEVER SUCCESSFUL;
AUDIT SELECT TABLE, UPDATE TABLE, INSERT TABLE BY hr BY ACCESS WHENEVER NOT SUCCESSFUL;

AUDIT ALL BY ACCESS;   -- alternatively, audit everything.
```

## Audit tables

```sql
AUDIT SELECT, INSERT, UPDATE ON hr.employees BY SESSION;
AUDIT SELECT, INSERT, UPDATE ON hr.employees BY SESSION WHENEVER SUCCESSFUL;
AUDIT SELECT, INSERT, UPDATE ON hr.employees BY SESSION WHENEVER NOT SUCCESSFUL;
AUDIT SELECT, INSERT, UPDATE ON hr.employees BY ACCESS;
AUDIT SELECT, INSERT, UPDATE ON hr.employees BY ACCESS WHENEVER SUCCESSFUL;
AUDIT SELECT, INSERT, UPDATE ON hr.employees BY ACCESS WHENEVER NOT SUCCESSFUL;
```

## View the audit trail

```sql
SELECT * FROM dba_audit_trail WHERE username = 'HR';   -- the audited actions of a user.
SELECT * FROM dba_stmt_audit_opts;                      -- the user-level audits enabled.
SELECT * FROM dba_obj_audit_opts;                       -- the object-level audits enabled.
```