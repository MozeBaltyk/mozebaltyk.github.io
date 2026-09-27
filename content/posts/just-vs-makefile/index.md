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
images: 
  - ./carousel/MakefileVsJustfile.webp
sidebar: false
---

Makefile VS Justfile

<!--more-->

## The cool stuffs with Makefile

Nothing to say, it's POSIX, so it's almost everywhere by default since 1976. So that's the reference: either you do better or worse than Make.

I can list a few points:

* Cool that it exists, and you should have gone through it.

* Make is a “task runner” and a “build tool”, since it's capable of not running a target if its dependencies are up-to-date, while justfile is just a "task runner".
  But on the other hand, `Just` just wants to be a "task runner"...

## The cool stuffs with Justfile

Here is a list of what justfile can do natively but Makefile cannot:

* `just --choose` - will let you choose among the recipes in interactive mode.

* Define your working dir: `just --justfile ~/.user.justfile --working-directory ~` (I am not convinced that you can do it with Makefile).

* Code precheck is highly appreciated.

```bash
bash: line 1: repository: unbound variable
error: Backtick failed with exit code 127
  |
4 | REPOSITORY := `if [ -n $repository ]; then echo "$repository"; else echo "github.com"; fi`
  |               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

* That's a big one, the Shebang recipes. A recipe can effectively be a Bash/Python/Node/etc. script without maintaining separate little script files.

```makefile
# Python directly inside your justfile
hello name:
    #!/usr/bin/env python3
    import sys

    name = "{{name}}"
    print(f"Hello {name}!")
```

No `scripts/hello.py`, no wrapper, everything stays in your `justfile`.

* Automatically document the recipes if a commented line is set just before the recipe, so when you execute `just --list`, you get:

```text
Available recipes:
    env repository='github.com' # env
    test                        # Test
```

* Possibility to make a hidden recipe for documentation, the default recipe (or even to complete this doc).
  Imagine that you need to create a custom PHONY with a beautiful `sed` to do the same in Makefile...

```makefile
_help:
    @printf "Some Title"
    @just --list --unsorted
    @printf "Some Extra infos"
```

* Hidden recipes from documentation.

* Possibility to create aliases for all the recipes automatically:

```bash
for recipe in `just -f ~/.justfile --summary`; do
  alias $recipe="just -f ~/.justfile -d. $recipe"
done
```

* Possibility to list in different orders:

```bash
just --list               # sorted in alphanumeric order  
just --list --unsorted    # sorted in the order given in the justfile
```

* Parameterization in Makefile will look like `make something -e CHOICE=test`; in justfile, `just something test`, since inside a justfile you can define arguments for your recipes.

* Autocompletion for your recipes:

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

* Syntax check. It will point to errors in your `justfile` code.

* Recipes can be written in arbitrary languages, like Python, NodeJS, or Bash.

* Just is a "task runner", and all the points listed above are going toward this purpose.

* Use the `[private]` attribute to make recipes invisible from the list.

* Group of receipes with tag `[group('Development')]`, here an example on how it render: 

```bash
➜  Colt git:(main) just
Available recipes:
    [Development]
    compile           # Build the binary.
    test              # Run the default Colt suite and lightweight repository checks.
    test-unit         # Fast unit lane: parsers, config, command generation, API mapping. No network.
    test-integration  # GITEA_PORT/FORGEJO_PORT (defaults 13000/13001), COLT_IT_KEEP=1 to debug.
    test-bdd          # Run every active deterministic BDD scenario (local fixtures only).
    test-bdd-blackbox # Build and smoke-test the real Colt binary in a sandbox.
    bdd-coverage      # Explicitly regenerate deterministic requirement-to-scenario coverage.
    check-tools       # the image with a read-only workspace and no Kubernetes credential mount.

    [Execution Environment]
    build             # Build the Execution Environment container image.
    push              # Push the Execution Environment image to the private registry.
    deploy            # Deploy the toolkit via the Helm chart (podman play kube).
    destroy           # Tear down the deployed toolkit pod.
    redeploy          # Destroy then redeploy.
    connect           # Launch the EE toolkit container and drop into an interactive shell.
```

## The Justfile's limitations

### The exported variables

One limitation that I got with justfile is that you cannot pass a variable that does not exist. Imagine you want to set a default behavior but allow your user to define another behavior. The code below does not work unless you define the var with `export repository=gitlab.com`. But the point here is to allow the user to not define the variable... This comes from Rust's safety paradigm.

```bash
bash: line 1: repository: unbound variable
error: Backtick failed with exit code 127
  |
4 | REPOSITORY := `if [ -n $repository ]; then echo "$repository"; else echo "github.com"; fi`
  |               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# Get the same error in case the env var is not defined, but still better than above condition.
REPOSITORY := env_var('REPOSITORY')
```

Ok, so what I wrote above is not true anymore. This was before I found [this](https://just.systems/man/en/chapter_37.html):

```bash
REPOSITORY := env_var_or_default('REPOSITORY', "github.com") 
```

### Variables in backticks

Another limitation, again with variables: you cannot use a variable defined before in a backtick. This below will generate an error:

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

But the limitations listed above seem to come from Rust's paradigm for safety and performance.

## Makefile Limitations

The documentation of all the PHONYs needs a PHONY for it. It should look like this:

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

## Conclusion

As you can see, the list is long and you end up with a beautiful tool that allows you to organize your tasks linked between them, auto-documented, and quite safe.

It tries to avoid the complexity and idiosyncrasies of `Makefile`. In some way, `Makefile` code is nested with your shell, and diving into an existing long script can become tedious.

## Other tips

* Create a CLI:

```shell
alias acme='just --justfile ~/acme/cli/justfile'
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

* Use tags in justfile:

```makefile
[private] # make the recipe invisible during list
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

## Bonus Point

usually I base my project on a [template](https://github.com/MozeBaltyk/project-template) using this justfile: 

```bash
➜  project-template git:(main) just
Available recipes:
    [Development]
    compile     # Build the binary. [This is just an example]
    test        # Run check the developer/support environment.
    test-bdd    # Run every active deterministic BDD scenario (local fixtures only).
    check-tools # the image with a read-only workspace and no Kubernetes credential mount.

    [Execution Environment]
    build       # Build the Execution Environment container image.
    push        # Push the Execution Environment image to the private registry.
    deploy      # Deploy the toolkit via the Helm chart (podman play kube).
    destroy     # Tear down the deployed toolkit pod.
    redeploy    # Destroy then redeploy.
    connect     # Launch the EE toolkit container and drop into an interactive shell.
```

## Sources

[Some Memo](https://cheatography.com/linux-china/cheat-sheets/justfile/)

[The Official doc](https://just.systems/man/en/)

[GitHub Casey/just](https://github.com/casey/just)

[Create some spell](https://dany98.hashnode.dev/just-harness-command-line-spells)

[Blog](https://blog.chay.dev/create-an-internal-cli/)
