---
date: 2024-08-04T21:00:00+08:00
title: 🔄 Data Guard
nav_weight: 110 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Databases
---

Synchronisation mechanism between two databases in Active/Passive.

## Switchover

```bash
dgmgrl sys@orcl
DGMGRL> switchover to 'orcl';
```

## Check primary / standby

```bash
echo -e "set heading off;\n select database_role FROM v\$database;" | sqlplus -S / as sysdba
# PHYSICAL STANDBY   (or PRIMARY)

echo -e "set heading off;\n select open_mode FROM v\$database;" | sqlplus -S / as sysdba
# MOUNTED             (a standby is mounted, not open)
```

* `PRIMARY` + `READ WRITE` → primary.
* `PHYSICAL STANDBY` + `MOUNTED` → standby.