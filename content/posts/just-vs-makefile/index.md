---
title: 👷👮 Makefile vs Justfile
description: "Comparing two popular task runners"
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
  - Building a Tool
categories:
  - Devops
tags:
  - Scripting
authors:
  - mozebaltyk
images:
  - ./carousel/MakefileVsJustfile.webp
sidebar: false
---

Makefile vs Justfile

<!--more-->

## What is great about Make?

There is not much to say about Make's availability: it has been around since 1976 and is installed by default on many Unix-like systems.

That makes it the reference point.

If you introduce another tool, it should solve a problem that Make does not solve well, or provide a noticeably better developer experience.

A few points are worth mentioning:

- Make is everywhere, and every developer or system administrator should probably have used it at least once.

- Make is both a **build tool** and a **task runner**.

  It understands dependencies and can decide not to rebuild a target when its dependencies are already up to date.

  `just`, on the other hand, deliberately focuses on being a **task runner**.

That difference is important.

Make was designed to build files efficiently.

`just` was designed to run commands conveniently.

## What is great about Just?

Here are some features that `just` provides natively and that are either unavailable or more cumbersome to implement with Make.

### Interactive recipe selection

```bash
just --choose
```

This lets you choose a recipe interactively.

### Define the working directory

```bash
just --justfile ~/.user.justfile --working-directory ~
```

This is particularly useful when using a global or shared `justfile`.

### Early error detection

One thing I appreciate is that `just` catches many mistakes before executing the recipe.

For example:

```bash
bash: line 1: repository: unbound variable
error: Backtick failed with exit code 127
  |
4 | REPOSITORY := `if [ -n $repository ]; then echo "$repository"; else echo "github.com"; fi`
  |               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

Getting an explicit error immediately is much better than discovering a problem halfway through a long task.

### Shebang recipes

This is a big one.

A recipe can directly contain a Bash, Python, Node.js, or other script without requiring a separate script file.

```makefile
# Python directly inside your justfile
hello name:
    #!/usr/bin/env python3
    import sys

    name = "{{name}}"
    print(f"Hello {name}!")
```

No `scripts/hello.py`, no wrapper — everything stays inside the `justfile`.

For small scripts and project utilities, this is extremely convenient.

### Built-in recipe documentation

If you add a comment before a recipe, `just --list` can display it automatically.

For example:

```text
Available recipes:
    env repository='github.com' # env
    test                        # Test
```

This makes it easy to build a small, self-documenting project CLI.

### Custom help recipes

You can also create your own hidden recipe and use it as the default entry point:

```makefile
_help:
    @printf "Some Title"
    @just --list --unsorted
    @printf "Some Extra infos"
```

Doing something similar with Make usually requires additional `.PHONY` targets and custom shell commands.

### Hidden recipes

Recipes can be hidden from the normal list when they are only implementation details.

The `[private]` attribute is useful for this:

```makefile
[private]
some-internal-task:
    echo "Internal task"
```

### Generate shell aliases

You can automatically create aliases for all available recipes:

```bash
for recipe in `just -f ~/.justfile --summary`; do
  alias $recipe="just -f ~/.justfile -d. $recipe"
done
```

This allows a `justfile` to behave almost like a small CLI.

### Recipe ordering

Recipes can be listed alphabetically:

```bash
just --list
```

or in the order in which they appear in the file:

```bash
just --list --unsorted
```

### Recipe arguments

With Make, passing parameters often looks something like this:

```bash
make something -e CHOICE=test
```

With `just`, recipe arguments are explicit:

```bash
just something test
```

Inside the `justfile`, the recipe can declare the parameters it expects.

This makes the command-line interface much clearer.

### Recipe autocompletion

`just` can provide completion for available recipes.

For example:

```bash
$ just
blank      -- Args: PROJECT *GROUP     # Create a new empty project on remote repository.
build      -- Args: PROJECT NAMESPACE  # Build collection locally.
clone      -- Args: PROJECT            # Clone a project from repository keeping directory structure for ansible.
clone_all  -- Args: *GROUP             # Git clone all projects from your repository, or if argument provided only from specific group.
init       -- Args: PROJECT *GROUP     # Create a new ansible collection on repository.
install    -- Args: PROJECT *VERSION   # Install an ansible collection. (if PROJECT is an artifact .tar.gz install local)
local      -- Args: PROJECT NAMESPACE  # Create a new ansible collection on localhost (not on repository like function below).
release    -- Args: PROJECT *VERSION   # Release collection on your repository to the given version in command or in galaxy.yml.
role       -- Args: GROUP PROJECT ROLE # Create a new ansible role inside an existing collection.
```

For larger projects, this turns the `justfile` into something close to a discoverable internal CLI.

### Syntax checking

`just` validates the syntax of the file and points directly to errors.

This is especially useful as the number of recipes grows.

### Recipes in arbitrary languages

Recipes can be implemented in Bash, Python, Node.js, and many other languages.

This is one of the features I find most useful because it avoids creating lots of tiny helper scripts.

### Recipe groups

Recipes can be grouped using attributes such as:

```makefile
[group('Development')]
```

For example:

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

This makes large `justfile`s much easier to navigate.

Overall, `just` remains focused on one thing:

**being a task runner.**

Most of its features are designed specifically around that goal.

## Justfile limitations

`just` is not perfect.

There are still a few limitations and behaviors worth understanding.

### Environment variables

One limitation I originally encountered involved optional environment variables.

I wanted to define a default behavior while still allowing the user to override it.

My first attempt looked like this:

```bash
bash: line 1: repository: unbound variable
error: Backtick failed with exit code 127
  |
4 | REPOSITORY := `if [ -n $repository ]; then echo "$repository"; else echo "github.com"; fi`
  |               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# Get the same error if the environment variable is not defined.
REPOSITORY := env_var('REPOSITORY')
```

At first, I considered this a limitation.

However, `just` already provides a better solution:

```bash
REPOSITORY := env_var_or_default('REPOSITORY', "github.com")
```

So this particular problem was mostly caused by my initial approach rather than by `just` itself.

### Variables inside backticks

Another limitation concerns variables evaluated inside backtick expressions.

For example:

```bash
set shell := ["bash", "-uc"]

REPO       := "github.com"
TEST       := "https://" + REPO
TEST2      := `curl https://{{TEST}}`

# Test
test:
    #!/usr/bin/env bash
    echo {{TEST}}
    echo {{TEST2}}
```

Depending on how values are evaluated, this kind of expression can become awkward.

In general, I prefer to keep complex runtime logic inside recipes instead of trying to put too much shell logic into top-level variable declarations.

That also makes the `justfile` easier to read.

## Makefile limitations for task running

Make is extremely powerful, but some of its design choices become awkward when the goal is simply to create a project CLI.

One example is documentation.

To generate a convenient help command for `.PHONY` targets, you often end up writing something like this:

```makefile
.PHONY: prerequis
## Install all prerequisites for this Ansible Collection.
prerequis:
        $(MAKE) -C ./scripts/prerequis all

# Keep this at the end of your Makefile
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

It works.

But compared with:

```bash
just --list
```

the amount of boilerplate is significant.

This illustrates the main difference between the two tools.

Make can absolutely be used as a task runner, but many features that `just` provides directly have to be implemented manually.

## Conclusion

The list of features is quite long, and the result is a very pleasant tool for organizing project tasks.

`just` gives you:

- Recipe arguments
- Built-in documentation
- Groups
- Private recipes
- Shell completion
- Shebang recipes
- Syntax validation
- Multiple scripting languages
- A clean CLI-oriented syntax

It tries to avoid much of the complexity and many of the historical conventions of Make.

With Make, the Make syntax and the shell syntax are often mixed together, and reading a large existing Makefile can become tedious.

That does not make Make obsolete.

Make is still the better tool when the actual problem is **building files based on dependencies and timestamps**.

But when the goal is simply:

> run a well-defined set of project commands

I now prefer `just`.

## Other tips

### Build a small CLI

A global `justfile` can easily become a personal command-line interface:

```shell
alias acme='just --justfile ~/acme/cli/justfile'
```

With a default recipe:

```makefile
[private]
@default:
  just --list

# Show architecture and OS name
@os-info:
  echo "Arch: {{arch()}}"
  echo "OS: {{os()}}"
```

You can then use:

```bash
acme
acme os-info
```

instead of maintaining a collection of unrelated shell scripts.

### Use platform-specific recipes

`just` can also provide recipes that differ depending on the operating system.

For example:

```makefile
[private]
@default:
  just --list

# Show architecture and OS name
@os-info:
  echo "Arch: {{arch()}}"
  echo "OS: {{os()}}"

# List systemd services
[linux]
@list-systemd-services:
  systemctl list-units --type=service

# Get the size of a folder
[linux]
[no-cd]
get-folder-size path:
  du -sh {{path}}

# Get the size of a folder in MB
[windows]
[no-cd]
get-folder-size path:
  (Get-ChildItem "{{path}}" -Recurse -Force | Measure-Object -Property Length -Sum).Sum / 1MB
```

This makes it possible to expose the same logical task while implementing it differently on Linux and Windows.

### Embed Python directly

Small Python utilities can live directly inside the `justfile`:

```makefile
# Scale a JPG image by 50%
[no-cd]
scale-jpg path:
  #!/usr/bin/env python3

  import PIL.Image
  image = PIL.Image.open("{{path}}")
  factor = 0.5
  image = image.resize((round(image.width * factor), round(image.height * factor)))
  image.save("{{path}}.s50.jpg")
```

### Use Nix for script dependencies

You can even combine `just` with Nix when a recipe requires additional dependencies:

```makefile
# Scale a JPG image by 50%
[no-cd]
scale-jpg path:
  #! /usr/bin/env nix-shell
  #! nix-shell -i python3 -p python3Packages.pillow

  import PIL.Image
```

That is a particularly interesting combination:

`just` defines the task, while Nix provides the execution environment.

## Bonus point

I usually start my projects from my
[project template](https://github.com/MozeBaltyk/project-template), which already includes a structured `justfile`.

For example:

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

This is where I find `just` particularly useful.

The `justfile` becomes the common entry point for the project:

```text
Developer
    │
    ▼
  just
    │
    ├── test
    ├── compile
    ├── build
    ├── deploy
    └── destroy
```

The underlying tools may change, but the developer interface remains simple and discoverable.

## Sources

- [Just cheat sheet](https://cheatography.com/linux-china/cheat-sheets/justfile/)
- [Official Just documentation](https://just.systems/man/en/)
- [GitHub — casey/just](https://github.com/casey/just)
- [Create some command-line spells](https://dany98.hashnode.dev/just-harness-command-line-spells)
- [Creating an internal CLI](https://blog.chay.dev/create-an-internal-cli/)
