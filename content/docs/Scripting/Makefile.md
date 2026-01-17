---
date: 2023-08-01T21:00:00+08:00
title: 👷 Makefile
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Scripting
  - Command-Liner
---


### Shell Variable
$$var
$$( python -c 'import sys; print(sys.implementation.name)' )

### Make Variable
T  ?=  foo                   # give a default value
T  :=  $(shell whoami)       # execute shell immediately to put in the var

### PHONY to execute several makefile

Example 1
```bash
SUBDIRS = foo bar baz

## dir is a Shell variables
## SUBDIR and MAKE are Internal make variables
subdirs:
        for dir in $(SUBDIRS); do \
          $(MAKE) -C $$dir; \
        done
```

Example 2
```bash
SUBDIRS = foo bar baz

.PHONY: subdirs $(SUBDIRS)
subdirs: $(SUBDIRS)
$(SUBDIRS):
        $(MAKE) -C $@
foo: baz
```

### Idea for a testing tools

```bash
git clone xxx /tmp/xxx&& make -C !$/Makefile
make download le conteneur
make build le binaire
make met le dans /use/local/bin
make clean
make help
```

### Sources:

[Tutorials](https://makefiletutorial.com/)

A [Gist](https://gist.github.com/klmr/575726c7e05d8780505a) for a colored help

The [RAW version](https://gist.githubusercontent.com/klmr/575726c7e05d8780505a/raw/5133761c901dc93c5dcc41f4a0446fe631c04713/Makefile)
