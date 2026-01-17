---
title: 👷👮 Makefile VS Justfile
description: "The two task-runners comparison!"
date: 2024-10-31T03:48:10+02:00
noindex: false
featured: true
draft: false
comment: true
toc: true
reward: true
pinned: false
carousel: true
series:
  - Posts
categories:
  - Devops
tags:
  - Command-liner
  - Scripting
authors:
  - mozebaltyk
images: [./MakefileVsJustfile/carousel.webp]
sidebar: false
---

Makefile VS Justfile

<!--more-->

## The cool stuffs with Makefile

Nothing to say, it's POSIX so it eveywhere almost by default since 1976 (47 years). So that's the reference, either you do better or worst than Make.   

I can list few points:  

* Cool that it exists and you should have went through.

* Make is “task runner” and “build tool” since it's capable to not run a target if a dependencies is up-to-date when justfile is just "task runner". 
  But on the other hand, `Just` just want to be a "task runner"...

## The cool stuffs with Justfile

Here a list of what justfile can do natively but not makefile:

* `just --choose` - will let you choose in interactif mode among the recipes.

* Define your work dir `just --justfile ~/.user.justfile --working-directory ~` (I am not convince that you can do it with Makefile) 

* Code Precheck is highly appreciate. 

```bash 
bash: line 1: repository: unbound variable
error: Backtick failed with exit code 127
  |
4 | REPOSITORY := `if [ -n $repository ]; then echo "$repository"; else echo "github.com"; fi`
  |               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

* Automaticly document the recipes if a commented line is set just before the recipe, so when you execute `just --list`, you get: 

```text
Available recipes:
    env repository='github.com' # env
    test                        # Test
```

* Possibility to make a hidden recipe for documentation, the default recipes (or even to complete this doc). 
Imagines that you need to create a custom PHONY with a beautifull sed to do the same in makefile... 

```makefile
_help:
    @printf "Some Title"
    @just --list --unsorted
    @printf "Some Extra infos"
```

* hidden recipes from documentation 

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

* Parameterization in makefile will look like `make something -e CHOICE=test`, in justfile `just something test` since inside an justfile, you can define arguments to your recipes.

* Autocompletion on your recipes

```bash
$ just
blank      -- Args: PROJECT *GROUP     # Create a new empty project on remote repository.
build      -- Args: PROJECT NAMESPACE  # Build collection locally.
clone      -- Args: PROJECT            # Clone a project from repository keeping directory structure for ansible.
clone_all  -- Args: *GROUP             # Git clone all projects from your repository, or if argument provided only from specific group.
init       -- Args: PROJECT *GROUP     # Create a new ansible collection on repository.
install    -- Args: PROJECT *VERSION   # Install a ansible collection. (if PROJECT is an artifact .tar.gz install local)
local      -- Args: PROJECT NAMESPACE  # Create a new ansible collection on localhost (not on repository like function below).
release    -- Args: PROJECT *VERSION   # Release collection on your repository to the given version in command or in galaxy.yml.
role       -- Args: GROUP PROJECT ROLE # Create a new ansible role inside an existing collection.
```

* Syntax Check. Will point to error in your `justfile` code. 

* Recipes can be written in arbitrary languages, like Python, NodeJS, bash.

* just a "task runner" and all the points listed above are going to this purpose.

* use tag `[private]` to make the recepies unvisible from the list


## The Justfile's limitation

### The exported variables

One limitation that I got with justfile is that you can not pass a variable which does not exist. Imagine, you want to set a default behavior but allow your user to define another bebavior. The code below does not work but if you define the var `export repository=gitlab.com`. But the point here is to allow the user to not define the variable... But this come from RUST safety paradigm. 

```bash 
bash: line 1: repository: unbound variable
error: Backtick failed with exit code 127
  |
4 | REPOSITORY := `if [ -n $repository ]; then echo "$repository"; else echo "github.com"; fi`
  |               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# Get the same error in case the env var is not defined, but still better than above condition.
REPOSITORY := env_var('REPOSITORY')
```

Ok, so what I wrote above is not true anymore. This was before, I found [this](https://just.systems/man/en/chapter_37.html):

```bash
REPOSITORY    :=  env_var_or_default('REPOSITORY', "github.com") 
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

## Conlcusion

As you can see, the list is long and you end up with a beautifull tool which allow you to organize your tasks linked between them, autodocumented, and quite safe.
It tries to avoid the complexity and idiosyncrasie of `Makefile`. In some way, `Makefile` code is nested with your shell and diving into an existing long script can become tedious. 
By the way, one project I did with justfile, [AnsiColt](https://github.com/MozeBaltyk/AnsiColt).

## Other tips


* Create a CLI:

```shell
alias acme='just --justfile ~/acme/cli/justfile'"
```

```makefile
[private]
@default:
  just --list

# Show arch and os name
@os-info:
  echo "Arch: {{arch()}}"
  echo "OS: {{os()}}"
```

* Use tags in justfile

```makefile
[private] # make the reciepe invisible during list
@default:
  just --list

# Show arch and os name
@os-info:
  echo "Arch: {{arch()}}"
  echo "OS: {{os()}}"

# List systemd services
[linux] # apply only to linux os
@list-systemd-services:
  systemctl list-units --type=service

# Get the size of a folder
[linux]
[no-cd] # apply from where you are
get-folder-size path:
  du -sh {{path}}

# Get the size of a folder in MB
[windows]
[no-cd]
get-folder-size path:
  (Get-ChildItem "{{path}}" -Recurse -Force | Measure-Object -Property Length -Sum).Sum / 1MB

### Script in Python3 ###
# scale jpg image by 50%
[no-cd]
scale-jpg path:
  #!/usr/bin/env python3

  import PIL.Image
  image = PIL.Image.open("{{path}}")
  factor = 0.5
  image = image.resize((round(image.width * factor), round(image.height * factor)))
  image.save("{{path}}.s50.jpg")

### use Nix to run python3 ###
# scale jpg image by 50%
[no-cd]
scale-jpg path:
  #! /usr/bin/env nix-shell
  #! nix-shell -i python3 -p python3Packages.pillow

  import PIL.Image
```


## source

[Some Memo](https://cheatography.com/linux-china/cheat-sheets/justfile/)

[The Offical doc](https://just.systems/man/en/)

[Github Casey/just](https://github.com/casey/just)

[Create some spell](https://dany98.hashnode.dev/just-harness-command-line-spells)

[Blog](https://blog.chay.dev/create-an-internal-cli/)