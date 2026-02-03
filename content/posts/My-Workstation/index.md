---
title: "My Workstation"
description: "Home, Oh sweet Home!"
date: 2026-01-18T20:45:00+01:00
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
  - Migration
images:
  - carousel/my-workstation.avif
authors:
  - mozebaltyk
sidebar: false
---

## What is a workstation ?

I keep in mind, **cattle not pet**, So I can change my PC, I would be able to kickstart my exact same workspace in 5 minutes. Once said, there is number things that I want to find back. it's not only config, but also the commands, the autocompletions, the plugins etc.

## To summarized

I would resume it as big bundle with:
- An OS
- A user space
- A Shell
- Some extra-commands coming from OS repositories
- Some extra-commands from some other repos or `arkade`.
- Some plugins
- The auto-completions on commands everytime its possible.
- Some dotfiles project which goes to `.config` for all the tools installed above.

## How to reach this ?

What would be the best way to reach this goal ?

- Some powershell script to trigger some WSL + shell scripts

- Some powershell script to trigger some WSL + Cloud-init

- A Dockerfile to build A container toolbox (the image would be too big - so I guess not a good option)

- NixOS with flake.nix and a declarative config file

I guess, I need to stay modulars in my approach.

## What about the dotfiles ?

What to do with `.config`? Popular solution is to transform `.config` as a git repository and save it time to time. Or more messy to create a project in hidden folder and use `stow` to handle all the symlink. Or even transform your entire `$HOME` directory as Git repository that ignores untracked files by default with a `gitignore` on some folder like `works`...

I see from this aproach one downsize, time to time you install some tool (for example `nvm`) and it write some output in the `.zshrc`. So it get messy and uncontrol since I want to deploy my workstation entirely, I got the risk to carry some config to some tools which is not installed by default...

So I want to keep my git as source of truce and local change to experiment on my workstation but update it on upstream Git repository with awareness.  

## Performance 

It's a concern, we expect that the terminal or a new shell open in less a second. Same for neovim...
So it will be good to dev some small script to test and get those metrics. 
