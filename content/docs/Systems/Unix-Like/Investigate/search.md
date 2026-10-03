---
date: 2023-08-17T21:00:00+08:00
title: 🔎 Search, Find & Compare
nav_weight: 10 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
---

## Find files quickly

```bash
locate <pattern>    # find a directory or file quickly (uses an index); a brand-new file won't be found.
updatedb            # update the locate index.
```

## Open a file

```bash
view <file>             # opens a read-only vi view (preferred if you just want to search/view).
gzcat / zcat <file.gz>  # read a gzipped file.
```

## Info on a file or directory

```bash
stat </my/file>      # all info about a file (inode, creation, modification, access dates, etc.).
stat -f <FS>         # info about a filesystem.
stat -c%s $LOGFILE   # [scripting] get a precise value (size, modification date, etc.).
```

## grep

```bash
grep -w 'xyz'                # match the whole word.
grep -x 'Hello, world!'      # the whole line must match.
grep -c <pattern>            # count the matching lines.
grep -l "ERROR:" *.log       # search all .log files, list the files that match.
grep -L <pattern>            # inverse: list the files that do NOT match.
grep -f <patternfile> <file> # apply the patterns read from patternfile.
grep -i <pattern>            # ignore case.
grep -v <pattern>            # return the lines that do NOT match.
grep -m x <pattern>          # stop after x matching lines.
grep -n <pattern>            # show the line number.
grep -q <pattern>            # quiet: exit 0 if found, 1 (or 2) otherwise (for scripting).
grep -s <pattern>            # suppress permission/inexistent-file error messages.
grep -H <pattern>            # show the filename next to each matching line.
grep -h <pattern>            # do not show the filename (default behaviour).
grep -A x <pattern>          # also show x lines After.
grep -B x <pattern>          # also show x lines Before.
grep -C x <pattern>          # show x lines of context (A + B).
grep -a <pattern> <binary>   # search a binary file as if it were text.
```

```bash
egrep = grep -E   # for complex regular expressions.
```

```bash
# extract the 3rd field, then cut:
cat file | grep /u01/grid/19c | awk '{print $3}' | cut -f2 -d'"'
# is equivalent to:
cat file | grep -o /u01/grid/19c
```