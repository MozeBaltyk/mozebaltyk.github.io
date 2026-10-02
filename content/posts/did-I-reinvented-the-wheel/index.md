---
title: Did I Reinvent the Wheel?
description: "Follow-up article to \"The Bad, the Good and the Ugly Git\"."
date: 2026-10-03T12:00:00+02:00
noindex: false
featured: true
draft: true
comment: true
toc: true
reward: true
pinned: true
carousel: true
series:
  - Posts
categories:
  - Devops
tags:
  - Git
authors:
  - mozebaltyk
images:
  - ./carousel/reinvented-the-wheel.jpg
sidebar: false
---

## Once upon a time

A long time ago, I wrote an [article](https://mozebaltyk.github.io/posts/bad-good-ugly-git/) about all the trouble involved in handling several Git providers.

This reflection led me to imagine my own tool, [Ansicolt], which was initially a basic proof of concept: a simple *justfile/bash* wrapper on top of `gh`, `glab`, and `git`.

I was already aware of tools like *gita* for managing multiple repositories, but they did not fully cover my needs.

So, what exactly was missing?

## The Specs

What did I want?

At first, the requirements were quite simple:

- Handle several Git providers.
- Handle several accounts and identities.
- Work with both HTTPS and SSH.
- Clone and create repositories without having to remember provider-specific commands.
- Manage group of repositories from one place.
- Keep using the standard `git` command for normal Git operations.
- Add some abstraction around provider APIs without trying to replace Git itself.

Over time, the scope naturally became a little larger, with things such as workspaces, repository synchronization, mirroring, releases, and self-hosted providers.

## The Tools Out There

### Provider CLIs: *gh*, *glab*, and *tea*

The obvious tools are the provider-specific CLIs.

For GitHub, there is `gh`.

For GitLab, there is `glab`.

For Gitea and Forgejo, there is `tea`.

Those tools are very powerful and cover most provider-specific operations.

The problem is that, when working with several providers, you have to remember which command belongs to which ecosystem. You may end up switching between them. while still using `git` itself for repository operations.

Each tool is good at what it does, but the workflow becomes fragmented.

### The Independent Projects

Of course, I am not the first one to face the problem of managing repositories spread across different providers.

There are several independent projects trying to add another abstraction layer on top of Git and provider APIs.

[Hyperforge](https://github.com/hypermemetic-ai/hyperforge) takes a declarative approach to multi-forge repository management.

It can manage repositories across GitHub, GitLab, and Codeberg, with the idea of having an origin and eventually mirrors on other forges.

[Coco](https://coco.griffen.codes/docs/getting-started) goes further than repository management.

It provides a Git terminal workstation with AI-assisted commits, reviews, and changelogs, but it also abstracts some forge operations.

It detects the remote provider and can use `gh` for GitHub, `glab` for GitLab, or APIs for some other forges.

[Gitfleet](https://github.com/airscripts/gitfleet) tries to provide a provider-neutral CLI for GitHub and GitLab.

Instead of remembering which command belongs to `gh` or `glab`, the idea is to expose a common vocabulary for repositories, issues, pipelines, releases, and other provider operations.

[RepoBee](https://github.com/repobee/repobee) was designed for teachers and teaching assistants managing a large number of student repositories. It supports GitHub, GitLab, and Gitea.

Still, the underlying problem is familiar: performing the same operations across tens or hundreds of repositories without having to manage each one manually.

[ghq](https://github.com/x-motemen/ghq) focuses more on organizing local repositories. It maps clones into paths such as `~/ghq/github.com/user/project`.

[mani](https://github.com/alajmo/mani) lets you declare a set of repositories and work across them. It can synchronize a declared repository collection and execute commands across all projects.

[gita](https://github.com/nosarthur/gita) — not to be confused with *Gitea*, which is a Git hosting platform — focuses on local multi-repository orchestration. If I remember correctly, it is written in Python. It helps manage several local repositories, but it does not try to abstract the forge itself.

Those projects have different goals, but they illustrate the same thing: as soon as you start working with several Git providers and a large number of repositories, `git` alone no longer covers the whole workflow.

So at least I know one thing:

I am not the only one struggling with this problem.

### To Summarize

So what should we use? The original tools such as `git`, `gh`, `glab`, and `tea`? One of the already existing independent projects? Or yet another custom tool?

The different projects do not solve exactly the same problem.

A very simplified view could look like this:

```txt
                  Local repos        Forge APIs       Identity/Auth
                      │                  │                  │
ghq / mani / gita ────●                  │                  │
                                         │
gh / glab / tea       ●──────────────────●                  ●
                                         │
git-profile           │                  │                  ●
                                         │
Gitfleet              │──────────────────●                  ●
                                         │
Hyperforge            ●──────────────────●──────────────────●
                                         │
Colt                  ●──────────────────●──────────────────●
                         + lifecycle / mirroring / self-hosting
```

This is obviously not a complete feature comparison. It is more a way to visualize where each project puts its abstraction layer:

- Some tools focus on local repositories.

- Some focus on provider APIs.

- Some focus on identities and authentication.

- Some try to cover several of those areas at once.

Which brings me back to my own *Colt*.

## Finally, My [*Colt*](https://github.com/MozeBaltyk/Colt)

At this point, the obvious question is: **Did I reinvent the wheel?**

Probably, at least partially. Many of the individual problems I wanted to solve already had their own tools. But I did not find a single one that matched exactly the workflow I wanted.

So sometimes, it is worth reinventing your own wheel, and this is where *Colt* eventually found its place.

There is also the learning path to consider.

This project took me from understanding and managing Git repositories to actually building a CLI tool in Go. It was a very practical way to learn the language and to create my first command-line application using *Cobra*.

In that sense, even if parts of the wheel already existed, rebuilding them myself was part of the point.

## Basic Usage of Colt

Before going further, let's have a quick look at how Colt is actually used.

### On Linux or macOS, Colt can be installed with:

```bash
curl -fsSL https://raw.githubusercontent.com/MozeBaltyk/Colt/main/install.sh | bash
```

### It can also be built directly from source:

```bash
CGO_ENABLED=0 go build -o colt ./cmd/colt
```

### Configure a Provider:

```bash
colt auth login github personal \
  --namespace my-user \
  --git-name "My Name" \
  --git-email me@example.com \
  --default
```

### Check the configured providers with:

```bash
colt auth status
```

The important point is that each provider configuration can have its own Git identity, authentication, namespace, and transport (without changing my global Git configuration).

So I can have something like:

```text
personal  -> GitHub  -> personal identity
work      -> GitLab  -> company identity
internal  -> Forgejo -> internal identity
```

### Create a new repository:

```bash
colt init my-project
```

Colt creates the remote repository, clones it locally, initializes it, and pushes the initial commit.

If I want to explicitly choose a provider:

```bash
colt init my-project --provider work
```

I can also create a repository locally without creating anything on a forge:

```bash
colt init my-project --local
```

After that, normal Git operations remain normal Git operations:

```bash
git add .
git commit -m "Initial implementation"
git push
```

Colt does not try to replace those commands.

### List and Clone Repositories:

Repositories available on a provider can be listed with:

```bash
colt list
```

Or across all configured providers:

```bash
colt list --all
```

A repository can then be cloned with:

```bash
colt clone my-project
```

or from a specific provider:

```bash
colt clone my-project --provider work
```

This is one of the basic ideas behind Colt.

Instead of remembering:

```text
Which forge is this?
Which CLI should I use?
Which account?
Which identity?
HTTPS or SSH?
```

I select the provider configuration and let Colt handle that context.

### HTTPS or SSH

A provider can use either HTTPS or SSH.

For example:

```bash
colt auth login github personal \
  --namespace my-user \
  --git-name "My Name" \
  --git-email me@example.com \
  --transport ssh
```

Colt does not manage SSH private keys itself.

With SSH, it relies on the existing SSH agent and configuration.

With HTTPS, authentication is handled through the configured credential mechanism without placing tokens in repository URLs.

### Working With Several Providers

This becomes more useful once several providers are configured.

For example:

```bash
colt list --provider personal
colt list --provider work
colt list --provider internal
```

Creating repositories works the same way:

```bash
colt init website --provider personal
colt init backend --provider work
colt init experiment --provider internal
```

The command stays mostly the same.

Only the provider context changes.

That was one of the main things I wanted from the beginning.

### Workspaces

Colt can also declare several repositories as a workspace. The general idea is that for Github a Workspace equal an organisation for Gitlab a workspace equal a repository group.  

For example:

```yaml
workspace:
  repositories:
    - provider: personal
      namespace: my-user

    - provider: work
      namespace: my-team
```

The current state can then be inspected with:

```bash
colt status
```

And missing repositories can be cloned with:

```bash
colt sync
```

There is also a dry-run mode:

```bash
colt sync --dry-run
```

From simply being a provider-neutral CLI, *Colt* start to manage the lifecycle of a collection of repositories.

### Releases

A release can also be created through Colt:

```bash
colt release v1.0.0
```

Colt creates the local Git tag, pushes it, and then creates the corresponding release through the provider API.

Again, the idea is to keep the same command regardless of whether the repository is hosted on GitHub, GitLab, Gitea, or Forgejo.

