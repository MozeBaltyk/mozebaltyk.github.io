---
date: 2023-08-27T21:00:00+08:00
title: 🚩 Compare
navWeight: 530 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Systems
  - Unix-Like
  - Investigate
---

## Compare staffs

* Compare two jar files:
```bash
diff -W200 -y  <(unzip -vqq file1.jar | awk '{ if ($1 > 0) {printf("%s\t%s\n", $1, $8)}}' | sort -k2) <(unzip -vqq  file2.jar | awk '{ if ($1 > 0) {printf("%s\t%s\n", $1, $8)}}' | sort -k2)
```		
 