---
date: 2023-08-27T21:00:00+08:00
title: 🚩 Compare
nav_weight: 50 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
---

## Compare files

```bash
diff <file1> <file2>       # -w to ignore whitespace.
colordiff <file1> <file2>  # colourised diff.
wdiff <file1> <file2>      # word diff: [− −] replaced word, {+ +} added word.
vimdiff <file1> <file2>    # open both files in vim (blue = entirely different lines, red = partially different).
fgrep -f <list> <file>     # compare two lists (e.g. of hosts).
```

## Compare jar files

```bash
diff -W200 -y  <(unzip -vqq file1.jar | awk '{ if ($1 > 0) {printf("%s\t%s\n", $1, $8)}}' | sort -k2) <(unzip -vqq  file2.jar | awk '{ if ($1 > 0) {printf("%s\t%s\n", $1, $8)}}' | sort -k2)
```