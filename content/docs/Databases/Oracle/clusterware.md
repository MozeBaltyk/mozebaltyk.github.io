---
date: 2024-08-01T21:00:00+08:00
title: Clusterware
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - DBA
tags:
  - Oracle
  - HA
---

## Grid

The grid is the component responsable for Clustering in oracle.

Grid (couche clusterware) -> ASM -> Disk Group 
    - Oracle Restart = Single instance = 1 Grid (with or without ASM)    
    - Oracle RAC OneNode = 2 instances Oracle in Actif/Passif with shared storage
    - Oracle RAC (Actif/Actif)

## SCAN

```bash
# As oracle user:
srvctl config scan

SCAN name: host-env-datad1-scan.domain, Network: 1
Subnet IPv4: 172.16.228.0/255.255.255.0/ens192, static
Subnet IPv6:
SCAN 1 IPv4 VIP: 172.16.228.33
SCAN VIP is enabled.
SCAN VIP is individually enabled on nodes:
SCAN VIP is individually disabled on nodes:
SCAN 2 IPv4 VIP: 172.16.228.35
SCAN VIP is enabled.
SCAN VIP is individually enabled on nodes:
SCAN VIP is individually disabled on nodes:
SCAN 3 IPv4 VIP: 172.16.228.34
SCAN VIP is enabled.
SCAN VIP is individually enabled on nodes:
SCAN VIP is individually disabled on nodes:
```

## Oracle 

* Instance resources:

```bash
# As oracle user
srvctl config database
srvctl config database -d <SID>  
srvctl status database -d <SID> 
srvctl status nodeapps -n host-env-datad1n1
srvctl config nodeapps -n host-env-datad1n1  
# ============
srvctl stop database -d DB_NAME
srvctl stop database -d DB_NAME -o normal
srvctl stop database -d DB_NAME -o immediate
srvctl stop database -d DB_NAME -o transactional
srvctl stop database -d DB_NAME -o abort
srvctl stop instance -d DB_NAME -i INSTANCE_NAME
# =============
srvctl start database -d DB_NAME -n host-env-datad1n1
srvctl start database -d DB_NAME -o nomount
srvctl start database -d DB_NAME -o mount
srvctl start database -d DB_NAME -o open
# ============
srvctl relocate database -db DB_NAME -node host-env-datad1n1
srvctl modify database -d DB_NAME -instance DB_NAME 
srvctl restart database -d DB_NAME
# === Do not do it
srvctl modify instance -db DB_NAME -instance DB_NAME_2 -node host-env-datad1n2
srvctl modify database -d DB_NAME -instance DB_NAME 
srvctl modify database -d oraclath -instance oraclath
```

* Cluster resources

```bash
crs_stat
crsctl status res
crsctl status res -t
crsctl check cluster -all

# Example how it should look:
/opt/oracle/grid/12.2.0.1/bin/crsctl check cluster -all
**************************************************************
host-env-datad1n1:
CRS-4535: Cannot communicate with Cluster Ready Services
CRS-4529: Cluster Synchronization Services is online
CRS-4534: Cannot communicate with Event Manager
**************************************************************
host-env-datad1n2:
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online
**************************************************************
```

```sql
show parameter cluster

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
cdb_cluster                          boolean     FALSE
cdb_cluster_name                     string      DB_NAME
cluster_database                     boolean     TRUE
cluster_database_instances           integer     2
cluster_interconnects                string
```

* Stop/start secondary node:

```sql
-- Prevent Database to switch over
ALTER database cluster_database=FALSE;
```

```bash
# as root
/u01/oracle/base/product/19.0.0/grid/bin/crsctl stop crs -f
/u01/oracle/base/product/19.0.0/grid/bin/crsctl disable crs

# Shutdown/startup VM or other actions

# as root
/u01/oracle/base/product/19.0.0/grid/bin/crsctl enable crs
/u01/oracle/base/product/19.0.0/grid/bin/crsctl start crs
```

* Stop/Start properly DB on both nodes:

```bash
# as oracle user
srvctl stop database -d oraclath

# As root user, on both nodes:
/opt/oracle/grid/12.2.0.1/bin/crsctl stop crs -f
/opt/oracle/grid/12.2.0.1/bin/crsctl disable crs

# As root user, on both nodes:
/opt/oracle/grid/12.2.0.1/bin/crsctl enable crs
/opt/oracle/grid/12.2.0.1/bin/crsctl start crs

# checks after restart 
ps -ef | grep asm_pmon | grep -v "grep"

# if ASM is up and running
srvctl start database -d oraclath -node host1-env-data1n1.domain
```

* Listner issue

```bash
# As oracle user
srvctl status scan_listener

PRCR-1068 : Failed to query resources
CRS-0184 : Cannot communicate with the CRS daemon.
```

the solution:

```bash
# As oracle
. oraenv  # +ASM1
sqlplus / as sysasm
startup

# As root
/opt/oracle/grid/12.2.0.1/bin/crsctl stop crs -f
/opt/oracle/grid/12.2.0.1/bin/crsctl start crs
```

Result:

```bash
srvctl status scan_listener
SCAN Listener LISTENER_SCAN1 is enabled
SCAN listener LISTENER_SCAN1 is running on node host1-env-data1n1.domain
SCAN Listener LISTENER_SCAN2 is enabled
SCAN listener LISTENER_SCAN2 is running on node host1-env-data1n1.domain
SCAN Listener LISTENER_SCAN3 is enabled
SCAN listener LISTENER_SCAN3 is running on node host1-env-data1n1.domain
```