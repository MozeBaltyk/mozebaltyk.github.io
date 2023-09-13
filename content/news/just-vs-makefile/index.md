---
# type: docs 
title: 👷👮 Makefile VS Justfile
date: 2023-08-21T03:48:10+02:00
featured: true
draft: true
comment: true
toc: true
reward: true
pinned: false
carousel: true
series:
  - Articles
  - Command-liner
categories:
  - Blog
tags:
  - Command-liner
  - Dev
authors:
  - mozebaltyk
images: [./MakefileVsJustfile/carousel.webp]
---

Makefile VS Justfile

<!--more-->

## The cool stuffs with Justfile

Here a list of what justfile can do but not makefile:

* `just --choose` - will let you choose in interactif mode among the recipes.   

* Define your work dir `just --justfile ~/.user.justfile --working-directory ~` (I am not convince that you can do it with Makefile) 

* Automaticly document the recipes if a commented line is set just before the recipe, so when you execute `just --list`, you get: 

```text
Available recipes:
    env repository='github.com' # env
    test                        # Test
```

* Possibility to make a hidden function to make the documentation, the default recipes (or even to complete this doc). 
Imagines that you need to create a custom PHONY with a beautifull sed to do the same in makefile... 

```makefile
_help:
    @printf "Some Title"
    @just --list --unsorted
    @printf "Some Extra infos"
```

* Possibility to create aliases for all the recipes automaticly: 

```bash
for recipe in `just -f ~/.justfile --summary`; do
  alias $recipe="just -f ~/.justfile -d. $recipe"
done
```

* Possibility to list in different order :

```bash
just --list               # sorted in an alphanumeric order  
just --list --unsorted    # sorted in the order given in the justfile
```


## The Justfile's limitation

### The exported variables

One limitation that I got with justfile is that you can not pass a variable which does not exist. Imagine, you want to set a default behavior but allow your user to define another bebavior. The code below does not work but if you define the var `export repository=gitlab.com`. But the point here is to allow the user to not define the variable... But this come from RUST safety paradigm. 

```bash 
bash: line 1: repository: unbound variable
error: Backtick failed with exit code 127
  |
4 | REPOSITORY := `if [ -n $repository ]; then echo "$repository"; else echo "github.com"; fi`
  |               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

### Variables in backtick

Another limitation, again with variable, cannot use variable define before in backtick. This below will generate an error because 

```bash
set shell := ["bash", "-uc"]

REPO       :=  "github.com"
TEST       :=  "https://" + REPO
TEST2      :=  `curl https://{{TEST}}`

# Test
test:
    #!/usr/bin/env bash
    echo {{TEST}}
    echo {{TEST2}}
```

But limitations listed above seems to come from RUST paradigm for safety and performance.


## Makefile Limitations

The documentation of all the PHONY need a PHONY for it. We should look like this: 

```makefile
.PHONY: prerequis
## Install all prerequisites for this Ansible Collections.
prerequis:
        $(MAKE) -C ./scripts/prerequis all

# keep it at the end of your Makefile
.DEFAULT_GOAL := show-help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
.PHONY: show-help
show-help:
        @echo "$$(tput bold)Available rules:$$(tput sgr0)"
        @echo
        @sed -n -e "/^## / { \
                h; \
                s/.*//; \
                :doc" \
                -e "H; \
                n; \
                s/^## //; \
                t doc" \
                -e "s/:.*//; \
                G; \
                s/\\n## /---/; \
                s/\\n/ /g; \
                p; \
        }" ${MAKEFILE_LIST} \
        | LC_ALL='C' sort --ignore-case \
        | awk -F '---' \
                -v ncol=$$(tput cols) \
                -v indent=19 \
                -v col_on="$$(tput setaf 6)" \
                -v col_off="$$(tput sgr0)" \
        '{ \
                printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
                n = split($$2, words, " "); \
                line_length = ncol - indent; \
                for (i = 1; i <= n; i++) { \
                        line_length -= length(words[i]) + 1; \
                        if (line_length <= 0) { \
                                line_length = ncol - indent - length(words[i]) - 1; \
                                printf "\n%*s ", -indent, " "; \
                        } \
                        printf "%s ", words[i]; \
                } \
                printf "\n"; \
        }' \
        | cat
```

## source

[Some Memo](https://cheatography.com/linux-china/cheat-sheets/justfile/)

[The Offical doc](https://just.systems/man/en/)

[Github Casey/just](https://github.com/casey/just)
