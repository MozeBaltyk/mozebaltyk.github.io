---
date: 2023-08-01T21:00:00+08:00
title: 🚦 Gita
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - Devops
tags:
  - Git
---


### Presentation 

Gita is opensource project in python to handle a bit number of projects available: [Here](https://github.com/nosarthur/gita)

```bash
# Install 
pip3 install -U gita

# add repo in gita
gita add dcc/ssg/toolset
gita add -r dcc/ssg          # recursively add
gita add -a dcc              # resursively add and auto-group based on folder structure

# create a group
gita group add docs -n ccn

# Checks
gita ls
gita ll -g
gita group ls
gita group ll
gita st dcc

# Use 
gita pull ccn
gita push ccn

gita freeze
```
