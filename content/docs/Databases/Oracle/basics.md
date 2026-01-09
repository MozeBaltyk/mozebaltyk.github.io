---
date: 2023-08-01T21:00:00+08:00
title: Oracle Basics
navWeight: 100 # Upper weight gets higher precedence, optional.
series:
  - DBA
categories:
  - Docs
tags:
  - Oracle
---

## Oracle DB Diagram

```mermaid
---
config:
  theme: forest
  layout: elk
---
flowchart TD
  subgraph s1["Instance DB"]
    style s1 fill:#E8F5E9,stroke:#388E3C,stroke-width:2px

    subgraph s1a["Background Processes"]
      style s1a fill:#FFF9C4,stroke:#FBC02D,stroke-width:1px
      n5["PMON (Process Monitor)"]
      n6["SMON (System Monitor)"]
      n10["RECO (Recoverer Process)"]
    end

    subgraph s1b["PGA (Process Global Area)"]
      style s1b fill:#E3F2FD,stroke:#1976D2,stroke-width:1px
      n1["Processes"]
    end

    subgraph s1c["SGA (System Global Area)"]
      style s1c fill:#FFEBEE,stroke:#D32F2F,stroke-width:1px
      subgraph n7["Shared Pool (SP)"]
        style n7 fill:#F3E5F5,stroke:#7B1FA2,stroke-width:1px
        n7a["DC (Dictionary Cache)"]
        n7b["LC (Library Cache)"]
        n7c["RC (Result Cache)"]
      end
      n8["DB Cache (DBC)"]
      n9["Redo Buffer"]
      n3["DBWR (DB Writer)"]
      n4["LGWR (Log Writer)"]
      n5["PMON (Process Monitor)"]
      n6["SMON (System Monitor)"]
      n10["RECO (Recoverer Process)"]
    end
  end

  subgraph s2["Database: Physical Files"]
    style s2 fill:#FFF3E0,stroke:#F57C00,stroke-width:2px
    n11["TBS (Tablespaces, files in .DBF)"]
    n12["Redo Log Files"]
    n13["Control Files"]
    n14["SPFILE (Binary Authentication File)"]
    n15["ArchiveLog files"]
  end

  subgraph s3["Operating System"]
    style s3 fill:#E0F7FA,stroke:#00796B,stroke-width:2px
    n16["Listener (Port 1521)"]
  end

  n3 --> n11
  n3 --> n7c
  n4 --> n12
  n6 --> n7a
  s3 --> s1
  s1c <--> n12
  s1c <--> n13
  s1c <--> n14
  n7b <--> n7c

  classDef Aqua stroke-width:1px, stroke-dasharray:none, stroke:#0288D1, fill:#B3E5FC, color:#01579B
  classDef Yellow stroke-width:1px, stroke-dasharray:none, stroke:#FBC02D, fill:#FFF9C4, color:#F57F17
  classDef Green stroke-width:1px, stroke-dasharray:none, stroke:#388E3C, fill:#C8E6C9, color:#1B5E20
  classDef Red stroke-width:1px, stroke-dasharray:none, stroke:#D32F2F, fill:#FFCDD2, color:#B71C1C

  class n11,n12,n13,n14,n15 Aqua
  class n5,n6,n10 Yellow
  class n1 Green
  class n7,n8,n9,n3,n4 Red
```

## Explanation 

An **Oracle server** includes an **Oracle Instance** and an **Oracle Database**.

### Oracle Instance

**PGA (Process Global Area)**: Handles calculations.

**SGA (System Global Area)** contains:
  - **DBC (DB Cache)**: When modification queries are made, it keeps the original row in a temporary undo file.
    - If another user requests the same information, the DB Cache will provide the result from the undo tablespace (i.e., before the modification). The modification must be "committed" for other users to see the latest update.
    - Two users cannot modify the same row simultaneously (thanks to the DB Cache).
  - **DBWR (DB Writer)**: Writes to the appropriate tablespace and updates the cache.
  - **LGWR (Log Writer)**: Writes to the REDO log.
  - **SP (Shared Pool)** contains three components:
    - **DC (Dictionary Cache)**: Stores metadata about the database.
    - **LC (Library Cache)**: If someone has already requested something and requests it again, the library cache indicates where the information is located.
    - **RC (Result Cache)**: Stores query results for reuse.

The **SGA** interacts with:
  - **SPFILE**: A binary file containing authentication information. (Alternatively, there is `init.ora`, which is a text file.)
  - **CTRL_File (Control File)**: The most important file, containing version information, the location of backups on disks, and the locations of database files.
  - **REDO**: (50 MB) A log of the most recent operations performed on the database.

- **Background Processes** :
  - **PMON (Process Monitor)**: Monitors processes.
  - **SMON (System Monitor)**: Updates the dictionary cache (DC) and tablespace information.
  - **RECO**