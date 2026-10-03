---
date: 2024-08-02T21:00:00+08:00
title: 🧪 Invalid Objects
nav_weight: 150 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Databases
---

## Find invalid objects

```sql
COL owner FOR a20
COL object_name FOR a50
COL subobject_name FOR a30

SELECT owner, object_name, subobject_name, object_type, created
FROM dba_objects WHERE status <> 'VALID' ORDER BY 2;
```

## Recompile — good practice after an import

```sql
SELECT COUNT(*) FROM dba_objects WHERE status = 'INVALID';
-- 61

@?/rdbms/admin/utlrp

SELECT COUNT(*) FROM dba_objects WHERE status = 'INVALID';
-- 40
```

## Recompile with a PL/SQL cursor

{{< code-snippet "oracle/recompile_invalid_objects.sql" "sql" >}}

## Drop invalid objects

{{< code-snippet "oracle/drop_invalid_objects.sql" "sql" >}}

{{< bs/alert warning >}}
`DROP <type> <name>` does not map one-to-one for every object type (e.g. there is no `DROP PACKAGE BODY`, and `SYNONYM`/`TRIGGER` need care). Prefer recompiling; drop only objects you are sure you no longer need.
{{< /bs/alert >}}