---
date: 2024-08-01T21:00:00+08:00
title: 🔧 Installation
nav_weight: 40 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Databases
---

## Sources & Docs

[Oracle-Base: DB 19c RAC installation on Oracle Linux 8 (VirtualBox)](https://oracle-base.com/articles/19c/oracle-db-19c-rac-installation-on-oracle-linux-8-using-virtualbox)

## Standards

Keep every Oracle installation as uniform as possible (easier automation). The points below are all required.

Example migration: previous install RAC ONE NODE SE (Grid 19.0.0 + udev/ASM, DB 12.2.0.1) → new RAC Active/Active EE (Grid 19.3 + AFD/ASM, DB 19.10).

### Users & groups

```bash
grep oracle /etc/passwd     # oracle:x:1521:1521:Oracle User For Database Binaries:/home/oracle:/bin/bash
grep oinstall /etc/group    # oinstall:x:1521:oracle
grep dba /etc/group         # dba:x:1522:oracle
```

### Filesystems & diskgroups

* `/u01` — a dedicated 100G filesystem (binaries ~25G + full install ~15G).
* `/tmp` — minimum 4G.
* `DATA` — ~60G raw devices / disks.
* `FRA` — minimum 4 disks × 20G (or 40G), raw devices / disks.
* `VOT` — minimum one 5G disk for the voting disk.

### Network

* Single instance: minimum two interfaces (public + backup/NFS).
* RAC: three interfaces:

```text
DEVICE  TYPE      CONNECTION
ens192  ethernet  Admin
ens224  ethernet  Interconnect
ens256  ethernet  Backup
```

One network interface for backups is required to mount an NFS share.

### ORACLE_HOME / ORACLE_BASE

```text
ORACLE_HOME = /u01/app/oracle/product/XX.X.X/dbhome_1
ORACLE_BASE = /u01/app/oracle/
CRS_HOME    = /u01/grid/19c/
```

### Database (dbca)

* DB name ≤ 8 characters (the SID is also ≤ 8 chars; the `db_unique_name` will differ from the SID).
* Fine-tuning parameters for a small DB:
  * `OPTIMIZER_MODE=FIRST_ROWS`
  * `processes=300`
  * `undo_retention=10800`
  * `NLS_SORT=BINARY`
  * `parallel_min_servers=0` (recommended) / `parallel_max_servers=10` (recommended)

### ASM diskgroup organisation

* one volume `DATA`
* one volume `FRA` (archivelogs)
* one volume `VOT` (voting disk + OCR)

### OMF & components

Activate OMF (see the Tablespace page). Install only the minimum modules:

```sql
SELECT comp_name FROM dba_registry;
-- Oracle Database Catalog Views
-- Oracle Database Packages and Types
-- Oracle Real Application Clusters
-- Oracle XML Database
-- Oracle Workspace Manager
```

### NLS

```sql
SET LINES 200 PAGES 2000
SELECT * FROM nls_database_parameters;
```

## Grid + ASM installation

### Prerequisites

```bash
# from the Grid package
cd /backup/INSTALL/GRID/cv/rpm
CVUQDISK_GRP=oinstall; export CVUQDISK_GRP
rpm -iv cvuqdisk-1.0.10-1.rpm
```

* RAC ONE NODE: only the public IP and the interconnect interface are configured; then 3 SCAN entries + one VIP per node in the DNS.
* Disable SELinux (at least during the install).

Pre-check:

```bash
cd /u01/oracle/base/product/19.0.0/grid
./runcluvfy.sh stage -pre crsinst -n node1,node2 -verbose | tee /home/oracle/check_cluster.log
```

### Manual install

```bash
mkdir /u01/oracle_bin
chown -R oracle:oinstall /u01

mkdir -p /u01/oracle/base/product/19.0.0/grid
unzip LINUX.X64_193000_grid_home.zip -d /u01/oracle/base/product/19.0.0/grid
```

Apply a patch (PSU) then launch:

```bash
/u01/oracle/base/product/19.0.0/grid/gridSetup.sh -applyPSU /u01/oracle_bin/19_GRID/psu/30501910
/u01/oracle/base/product/19.0.0/grid/gridSetup.sh
```

Grid installer choices:

* **External** redundancy (managed by the storage, not Oracle).
* **Discovery path** = the path defined by the udev rules.
* **ASM password** = the same for all.
* **OS groups** = `oinstall` everywhere.
* **Oracle base** = `/u01/oracle/base`.
* Run the root scripts (give the password).

### AFD (ASM Filter Driver)

```bash
# as root
$ORACLE_HOME/bin/afddriverstate supported
export ORACLE_HOME=/u01/grid/19c
$ORACLE_HOME/bin/crsctl stop has -f
$ORACLE_HOME/bin/asmcmd afd_configure
$ORACLE_HOME/bin/crsctl start has

# label devices
$ORACLE_HOME/bin/asmcmd afd_dsset "/dev/sd*"
$ORACLE_HOME/bin/asmcmd afd_label DATA001 /dev/sdc1 --init
$ORACLE_HOME/bin/asmcmd afd_label DATA002 /dev/sdd1 --init
$ORACLE_HOME/bin/asmcmd afd_label FRA001  /dev/sde1 --init
$ORACLE_HOME/bin/asmcmd afd_label VOT001  /dev/sdf1 --init
# if "ASMCMD-9521: AFD is already configured": use --migrate instead of --init
```

### Create the diskgroups

```bash
. oraenv +ASM

asmca -silent -createDiskGroup -diskGroupName DATA -diskList 'AFD:DATA*' -redundancy EXTERNAL
asmca -silent -createDiskGroup -diskGroupName FRA  -diskList 'AFD:FRA*'  -redundancy EXTERNAL
asmca -silent -createDiskGroup -diskGroupName OCR  -diskList 'AFD:VOT*'  -redundancy EXTERNAL

asmcmd lsdsk -G DATA
asmcmd dsset 'AFD:*'
```

## DB binary install

```bash
cd /u01/oracle_bin/database
./runInstaller            # software only, single instance, EE/SE
# software location: /u01/oracle/base/product/12.2.0/dbhome_1
```

As root:

```bash
/u01/oracle/base/product/12.2.0/dbhome_1/root.sh
```

Then create the database with `dbca`, and set the environment:

```bash
vi ~/.bash_profile
# export ORACLE_BASE=/u01/oracle/base
# export ORACLE_HOME=/u01/oracle/base/product/12.2.0/dbhome_1
# export CRS_HOME=/u01/oracle/base/product/19.0.0/grid
# PATH=$PATH:$ORACLE_HOME/bin:$ORACLE_HOME:OPatch:$CRS_HOME/bin
. ~/.bash_profile
```

## Create the database (DBCA)

Launch as `oracle` with X11 (or MobaXterm):

```bash
$ORACLE_HOME/bin/dbca
```

Steps (Advanced Configuration):

1. **Create a Database** → 2. **Advanced Configuration** → 3. **Single instance** or **RAC ONE Node**.
4. Database name (≤ 8 chars), storage type (ASM), Fast Recovery Area.
5. Enable **ARCHIVELOG** on `+FRA` (the FRA is where the archivelogs go).
6. Keep the **Listener** on the default.
7. Memory: "SGA + PGA (of each instance)" must not exceed the shared memory:

```bash
df -TPh /dev/shm
# tmpfs  tmpfs  3.9G  637M  3.2G  17% /dev/shm
```

Leave the defaults unless you have a reason. In "All Initialization Parameters", set the tuning values from the Standards section above (`OPTIMIZER_MODE=FIRST_ROWS`, `processes=300`, `undo_retention=10800`, `NLS_SORT=BINARY`, `parallel_min/max_servers`).

### Debug

```bash
ls /u01/oracle/base/cfgtoollogs/dbca/trace.log_*
ls /u01/oracle/base/diag/rdbms/*/*/trace/alert*
tail -500f /u01/oracle/base/diag/rdbms/orcl/ORCL/trace/alert_ORCL.log
```

### After creation — check

```sql
SELECT * FROM nls_database_parameters;
SELECT comp_name, version, status FROM dba_registry;
SHOW PARAMETER cursor;
SHOW PARAMETERS auth;
SHOW PARAMETERS pga;
SHOW PARAMETERS sga;
```

## Client install

### Instant Client

```bash
mkdir -p /appli/oracle/product/instantclient/19.10
cd /appli/oracle/product/instantclient/19.10
# move the zip, unzip, then:
mkdir lib bin
for i in adrci exp expdp genezi imp impdp sqlldr sqlplus uidrvci wrc; do mv ${i} bin/.; done
mv lib* lib/.
mv *.jar lib/.
mv glogin.sql lib/.
```

`.bash_profile`:

```bash
export ORACLE_HOME=/appli/oracle/product/instantclient/19.10
export PATH=$PATH:$ORACLE_HOME/bin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
```

### Client HOME

```bash
yum install compat-libstdc++-33 glibc-devel
su - oracle
mkdir -p /appli/oracle/product/19.03.0/client
cd /appli/oracle/product/19.03.0/client
unzip LINUX.X64_193000_client_home.zip

./runInstaller -waitforcompletion -silent -noconfig -force \
  -responseFile /appli/oracle/product/19.03.0/client/install/response/clientsetup.rsp
./runInstaller -executeConfigTools \
  -responseFile /appli/oracle/product/19.03.0/client/install/response/clientsetup.rsp -silent
# as root: orainstRoot.sh
```

## Uninstall

```bash
# as oracle
export ORACLE_HOME=/u01/grid/19c/
$ORACLE_HOME/bin/asmca -silent -deleteASM -force -dropDiskGroups

# as root
export ORACLE_HOME=/u01/grid/19c
$ORACLE_HOME/bin/asmcmd afd_unlabel DATA001
$ORACLE_HOME/bin/asmcmd afd_unlabel DATA002
$ORACLE_HOME/bin/asmcmd afd_unlabel FRA001
$ORACLE_HOME/bin/asmcmd afd_unlabel VOT001
$ORACLE_HOME/bin/crsctl stop has -f
$ORACLE_HOME/bin/acfsroot uninstall
$ORACLE_HOME/bin/asmcmd afd_deconfigure

# wipe the disks
dd if=/dev/zero of=/dev/sdc bs=1M count=1000   # ... for each ASM device ...

rm -rf /u01/app /u01/grid /etc/oraInst.loc /etc/oratab /etc/oracleafd.conf /opt/oracle/ /etc/oracle/ /var/tmp/.oracle
```