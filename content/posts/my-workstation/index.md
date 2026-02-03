---
title: "💻 My Workstation"
description: "Home, Oh sweet Home!"
date: 2026-02-03T01:00:00+01:00
draft: true
noindex: false
featured: true
pinned: false
comment: true
toc: true
reward: true
carousel: true
series: 
  - Posts
categories:
  - SysAdmin
tags:
  - Workstation
  - OpenSources
  - Linux
images:
  - ./carousel/my-workstation.avif
authors:
  - mozebaltyk
sidebar: false
---

## What is a workstation?

I keep the **“cattle, not pets”** mindset in mind. I want to be able to change my PC or just wipe and kickstart the *exact same* workspace in five minutes.

In my case, a workstation is primarily used for system administration and DevOps activities. This includes interacting with remote servers via SSH, managing Kubernetes clusters, writing and testing infrastructure-as-code, inspecting or debugging systems and much more.

The workstation must provide fast access to CLI tools and a familiar environment. More than raw performance, predictability and reproducibility across the team are also essential.

In this context, why Linux — and only Linux?

Linux naturally fits this context because most servers, containers, and cloud platforms already run on Linux. Using the same operating system on the workstation reduces the gap between development and production. For system administration and DevOps work, Linux is not just a preference — it is the environment closest to where the software will actually run.

## To summarize

I would describe a workstation as a big bundle containing:

- An OS - for sure Linux
- A user space
- A shell - in my case ZSH
- Extra commands coming from OS repositories
- Extra commands from external sources or tools like `arkade`
- Plugins
- Command auto-completion whenever possible
- A dotfiles project that populates `.config` for all the tools installed above
- Some secrets - SSH keys, API token, etc. but currently out of scope 

## How to reach this?

What is the best way to reach this goal? Disclaimer, my pro laptop provided by the company is on Windows, that's a constrain that I need to deal with. But WSL allow us to combine the best of both worlds.

Possible approaches:

- A PowerShell script that triggers WSL and then runs shell scripts
- A PowerShell script that triggers WSL with Cloud-Init
- A Dockerfile to build a containerized toolbox  
  (but the image would likely be too big, so probably not a good option)
- NixOS with `flake.nix` and a fully declarative configuration

Obviously, I need to stay **modular** in my approach. 

## What about dotfiles?

What should we do with `.config`?

A popular solution is to turn `.config` into a Git repository and commit it from time to time.  
Another, more explicit approach is to create a dedicated dotfiles project and use `stow` to manage symlinks.  
A more extreme option is to turn the entire `$HOME` directory into a Git repository that ignores untracked files by default, using a `.gitignore` for folders like `work/`.

I see a downside with these approaches: from time to time, you install a tool (for example `nvm`) and it writes directly to `.zshrc`. Over time, this becomes messy and uncontrolled.

Since I want to deploy my workstation entirely, I risk carrying configuration for tools that are not actually installed by default.

I want Git to be the **source of truth**, while still allowing local experimentation on my workstation, and only updating the upstream repository deliberately and consciously.

## Performance

Performance is a real concern. We expect a terminal or a new shell to open in under one second — same for Neovim.

It would be useful to develop small scripts to measure and track these metrics over time.
