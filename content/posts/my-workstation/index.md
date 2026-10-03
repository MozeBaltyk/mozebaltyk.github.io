---
title: "💻 My Workstation"
description: "Home, Oh Sweet Home!"
date: 2026-09-27T01:00:00+01:00
draft: false
noindex: false
featured: true
pinned: false
comment: true
toc: true
reward: true
series:
  - Workstation
categories:
  - Reflection
tags:
  - Linux
images:
  - carousel/my-workstation.avif
authors:
  - mozebaltyk
sidebar: false
---

## What is a workstation?

In my case, a workstation is primarily used for system administration and DevOps activities.

This includes interacting with remote servers through SSH, managing Kubernetes clusters, writing and testing infrastructure as code, inspecting or debugging systems, and much more.

A workstation must provide fast access to CLI tools and a familiar environment. More than raw performance, however, predictability and reproducibility are essential — especially when several people in a team need similar environments.

In this context, why Linux — and only Linux?

Linux naturally fits this use case because most servers, containers, Kubernetes nodes, and cloud platforms already run on Linux. Using the same operating system on the workstation reduces the gap between development and production.

For system administration and DevOps work, Linux is not just a preference. It is the environment closest to where the software will actually run.

## To summarize

I would describe a workstation as a big bundle containing:

- An OS — Linux, for sure
- A user space
- A shell — ZSH in my case
- Additional commands provided by the OS repositories
- Additional commands coming from external sources or tools such as `arkade`
- Shell plugins
- Command auto-completion whenever possible
- A dotfiles project that populates `.config` and other configuration files for the tools installed above
- Some secrets — SSH keys, API tokens, and so on — although secrets management is currently out of scope
- My technology watch, powered by RSS feeds

On top of that, I want to apply the **"cattle, not pets"** mindset.

For those unfamiliar with this principle, the idea is simple: I should be able to wipe my workstation and recreate the same environment from scratch in a few minutes.

If losing the machine means spending a day manually rebuilding the environment, then the workstation is still a pet.

## How can we achieve this?

What is the best way to reach this goal?

There is one important constraint: my professional laptop is provided by my company and runs Windows.

Fortunately, WSL allows me to combine both worlds: Windows remains the host operating system, while most of my administration and development environment lives inside Linux.

Several approaches are possible:

- A PowerShell script that manages WSL and triggers shell scripts inside the distribution
- A PowerShell script that provisions a WSL distribution using `cloud-init`
- A Dockerfile that builds a containerized toolbox
- NixOS with a `flake.nix` and a fully declarative configuration

The container approach is attractive because containers are inherently reproducible, but using a container as the complete interactive workstation introduces other compromises. The resulting image can also become quite large once all the tools are included.

NixOS takes declarative configuration much further and is probably one of the cleanest answers to the reproducibility problem. However, adopting Nix also means adopting its ecosystem, concepts, and tooling.

Whatever solution I choose, one requirement remains important: **the implementation must stay modular**.

I do not want one enormous installation script containing every decision about my workstation.

Each component should be independently understandable, replaceable, and ideally reusable.

## What about dotfiles?

Then comes another question: what should we do with `.config`?

A popular solution is to turn `.config` itself into a Git repository and commit changes from time to time.

Another, more explicit approach is to create a dedicated dotfiles repository and use a tool such as `stow` to manage symbolic links.

A more extreme option is to turn the entire `$HOME` directory into a Git repository while ignoring untracked files by default, with exceptions or `.gitignore` rules for directories such as `work/`.

All of these approaches can work, but I see one recurring problem.

Sometimes you install a tool — `nvm`, for example — and its installer modifies `.zshrc` directly. Other applications create or update configuration files automatically.

After some time, configuration that was initially clean and intentional can become messy.

More importantly, if my goal is to deploy the whole workstation from Git, I do not want the repository to become a dump of every configuration file that has ever existed on one particular machine.

The repository should describe the environment I **want to deploy**, not merely reflect the current state of my home directory.

I want Git to remain the **source of truth**, while still allowing local experimentation.

That means I should be able to modify a configuration locally, test it for a few days, and only push that change back into the repository deliberately.

The direction of synchronization matters:

**Git deploys the workstation. The workstation should not automatically define Git.**

## From the reflection to WST

This reflection eventually became a real project: [WST](https://github.com/MozeBaltyk/wst).

WST stands for the practical approach I currently use to bootstrap my workstation on top of WSL.

The project follows a simple idea:

**Windows handles orchestration, while Linux handles the Linux environment.**

At the top level, a PowerShell menu acts as the entry point. It can manage WSL distributions and perform a few Windows-specific setup or cleanup operations.

Inside Linux, the actual workstation bootstrap is handled separately.

The project currently relies on:

- PowerShell for Windows and WSL orchestration
- Bash for the Linux bootstrap logic
- `arkade` to install a number of CLI tools
- `just` as a task runner
- A dedicated `dotfiles` directory containing the configuration I deliberately want to deploy

This separation is important.

The Windows layer should not need to know how my ZSH environment is configured. The Linux bootstrap should not care whether the distribution was created manually or through the PowerShell menu. And the dotfiles should remain usable independently from the provisioning mechanism.

That modularity also means that parts of WST can evolve without rewriting the entire project.

For example, the Linux bootstrap can already be used independently on an existing WSL installation:

```bash
git clone https://github.com/MozeBaltyk/wst.git
cd wst/linux

just all
```

So WST is not really "one giant installation script".

It is an orchestration layer around several smaller and more focused components.

## Could `cloud-init` be the next step?

So far, I have never felt a strong need to move to NixOS.

I recognize that NixOS could be an interesting alternative, especially if I wanted the entire workstation state to become fully declarative.

However, `cloud-init` on WSL looks like a particularly interesting evolution for WST.

`cloud-init` is already widely used to initialize Linux systems, especially in cloud and virtualized environments. Ubuntu on WSL also supports using it to configure an instance automatically and reproducibly on first boot.

That fits very well with the problem I am trying to solve.

Instead of:

**PowerShell → create WSL → execute bootstrap scripts**

the workflow could gradually move toward something closer to:

**PowerShell → create WSL with `cloud-init` → WST configures the workstation**

The interesting part is not replacing WST with `cloud-init`.

Quite the opposite.

`cloud-init` could become another provisioning backend for WST.

The higher-level structure — packages, tools, dotfiles, shell configuration, and workstation conventions — can remain independent from the mechanism used to create the Linux instance.

This would also move WST closer to something that could bootstrap environments outside WSL.

## Other concerns

Reproducibility is not the only requirement.

Performance matters too.

A terminal or a new interactive shell should open in under one second. The same expectation applies to tools such as Neovim.

A reproducible workstation that takes five seconds to start every shell would technically solve one problem while creating another.

It would therefore be useful to develop a few small scripts to measure these metrics and track them over time.

For example, WST already gives me a simple way to measure ZSH startup time:

```bash
time zsh -i -c exit
```

These measurements could eventually become regression tests for the workstation itself.

Another concern is avoiding unnecessary vendor lock-in or becoming too dependent on a single Linux distribution.

This is also why keeping the Linux bootstrap, dotfiles, and orchestration layers separated is useful.

Today, WST is strongly oriented toward WSL, but as much as possible, the configuration itself should remain regular Linux configuration.

Staying curious, experimenting with new tools, replacing components, and occasionally questioning previous choices are all part of working in IT.

The workstation should make those experiments easy without sacrificing the ability to return to a known state.

## Conclusion

The goal was never simply to automate the installation of a few CLI tools.

The real goal was to define **what my workstation is**.

It should be reproducible, modular, fast, understandable, and stored in Git.

Windows and WSL are constraints of my current professional environment, but they do not have to dictate how the Linux side of the workstation is designed.

That reflection is what led me to build [WST](https://github.com/MozeBaltyk/wst).

WST is therefore less a collection of installation scripts than the executable definition of my workstation.

Today, PowerShell, Bash, `arkade`, `just`, and dotfiles are the tools used to implement that definition.

Tomorrow, `cloud-init` may become another layer in the process.

The implementation can change.

The important part is that I should always be able to wipe the environment, recreate it, and feel immediately at **home** again.

## Sources

- [WST](https://github.com/MozeBaltyk/wst)
- [Ubuntu on WSL — cloud-init](https://documentation.ubuntu.com/wsl/stable/howto/cloud-init/)