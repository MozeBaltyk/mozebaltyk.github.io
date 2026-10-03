---
title: 👺 The Bad, the Good and the Ugly Git
description: "When it comes to IT, Git cannot be ignored... even for infrastructure guys!"
date: 2024-10-28T03:48:10+02:00
noindex: false
featured: true
draft: false
comment: true
toc: true
reward: true
pinned: true
series:
  - Building a Tool
categories:
  - Reflection
tags:
  - Git
authors:
  - mozebaltyk
images:
  - carousel/bad-good-ugly-git.jpg
sidebar: false
---

## The bad surprise

A few days ago, I was wondering why my commits were not being counted in my GitHub Activity Dashboard after a good day of pushing code...

After a quick investigation, I noticed that in my project directory, `git config user.name` and `git config user.email` were not set.

I checked my latest commit on GitHub, and indeed, the push had been made using the values from `git config --global user.name`.

Not a big deal, but this revealed my name when I would have preferred to remain anonymous — just a personal choice.

## A good solution

This surprise pushed me to develop a tool called [AnsiColt](https://github.com/MozeBaltyk/AnsiColt) (which is now a *retired* project) to handle the creation of Ansible Collections and manage the various projects that I maintain across repositories split between GitHub and GitLab.

This project recently evolved into [Colt](https://github.com/MozeBaltyk/Colt).

One of my recurring hassles is that I am involved in projects stored on different version-control platforms such as GitHub and GitLab.

During the cloning process, I did not immediately configure the user identity individually for each project, so Git fell back to the global configuration instead.

Here is the joy of coding, Continuous Integration, and a good opportunity to kick-start my blog with a fairly ordinary story...

## And an opportunity...

Let's have a quick reminder of some Git basics!

There are plenty of articles and tutorials on the Internet, but this article is going to serve as my personal notes on the topic.

Each local project has a hidden `.git` directory containing its own `.git/config`, but you also have a `.gitconfig` file in your home directory, which contains the global configuration applied to all your Git repositories.

So when Git does not find the user name and email in the `.git/config` of your project, it gets them from the global `~/.gitconfig`, if they are defined there.

This becomes relevant when you are managing many projects across public repositories, personal projects, and on-premise repositories.

Usually, you can simply set the identity individually for a repository:

```bash
# Setup
cd ~/my_project
git config user.name "john.smith"
git config user.email "john.smith@example.com"

# Check the local configuration
git config user.name
git config user.email

# Check the global configuration
git config --global user.name
git config --global user.email
```

This works perfectly well, but it also means that I have to remember to do it **every time I clone a new repository**.

And this was exactly the origin of my bad surprise...

### Conditional Git configuration

There is actually a more elegant solution that I had overlooked: Git supports conditional configuration with `includeIf`.

Instead of configuring the identity repository by repository, you can organize your repositories into directories and tell Git to load a different configuration depending on where the repository is located.

For example, let's say that I organize my repositories like this:

```text
~/git/
├── github/
│   ├── my-blog/
│   ├── ansible-collection/
│   └── another-public-project/
│
└── company/
    ├── infrastructure/
    ├── terraform/
    └── internal-project/
```

I can then define the following in my global `~/.gitconfig`:

```cfg
[includeIf "gitdir:~/git/github/"]
    path = ~/.gitconfig-github

[includeIf "gitdir:~/git/company/"]
    path = ~/.gitconfig-company
```

And create a configuration dedicated to my public GitHub projects:

```cfg
# ~/.gitconfig-github

[user]
    name = MozeBaltyk
    email = my-public-email@example.com
```

While my company repositories can use another identity:

```cfg
# ~/.gitconfig-company

[user]
    name = John Smith
    email = john.smith@company.example
```

Now, if I clone a project under:

```bash
cd ~/git/github
git clone https://github.com/example/project.git
```

Git will automatically load `~/.gitconfig-github`.

But if the repository is under:

```text
~/git/company/
```

it will load `~/.gitconfig-company` instead.

There is no longer any need to remember to run:

```bash
git config user.name ...
git config user.email ...
```

after every clone.

You can see exactly where a configuration value comes from with:

```bash
git config --show-origin user.name
git config --show-origin user.email
```

Or display the entire configuration and its origins:

```bash
git config --list --show-origin
```

This is particularly useful with `includeIf`, because several configuration files can now contribute to the final Git configuration.

### Local, global... and conditional

So in the end, my initial mistake was not really a Git problem.

Git did exactly what I asked it to do: no identity was configured locally, so it fell back to the identity from my global configuration.

The problem was rather how I had organized my configuration.

Setting `user.name` and `user.email` locally works when you only have a few repositories.

But when you start juggling personal projects, public projects, company repositories, and different Git providers, `includeIf` becomes much more interesting.

And there is another important distinction here: `user.name` and `user.email` define **the identity written into my commits**.

They do not define **how I authenticate against GitHub or GitLab**.

That is another story involving HTTPS tokens, SSH keys, and credential helpers...

## Git authentication

On a public repository, you are usually allowed to clone without authentication, but when it comes to pushing to the remote origin, Git needs an authentication mechanism.

* HTTPS protocol, usually the default choice.

In `.git/config`, by default, you will find something like:

```cfg
[remote "origin"]
        url = https://github.com/MozeBaltyk/Colt.git
```

But it will request authentication every time you push, which is where OAuth2 tokens come in.

```cfg
[remote "origin"]
        url = https://oauth2:xxxxxxxxxxxx@github.com/MozeBaltyk/Colt.git
```

You can configure this globally from the command line if you do not want to edit the `.git/config` of each repository.

```bash
# Connect with token
git config --global url."https://${username}:${access_token}@github.com".insteadOf "https://github.com"
```

* SSH protocol.

If the SSH public key is configured on GitHub, define your `~/.ssh/config` like this:

```cfg
# ~/.ssh/config
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/ed25519
```

Test it:

```bash
➜  ~ ssh -T github.com
Hi MozeBaltyk! You've successfully authenticated, but GitHub does not provide shell access.
```

Then, in the `.git/config` of your project, set the remote origin using the SSH protocol as shown below:

```cfg
[remote "origin"]
        url = git@github.com:MozeBaltyk/Colt.git
```

In fact, this is often forgotten: this model is also available on a bare Linux host.

Anyone can use Git through a local SSH server.

One word about the choice of protocol.

It may sound obvious, but SSH usually goes through port 22.

Some companies block outgoing connections to port 22, so in that sense HTTPS is more standard and easier to use through corporate networks.

GitHub no longer allows password authentication for Git operations over HTTPS, but you can use a **Personal Access Token** instead.

The question then becomes how and where to securely store this token.

## The provider CLI tools: `gh` or `glab`

What we saw earlier is the standard `git` command used to manage your projects.

But you are limited to Git operations and excluded from provider-specific operations such as creating issues, opening pull requests, and so on.

Provider CLIs also allow you to choose between HTTPS and SSH.

Usually, these tools use `~/.config/` to store protocol preferences, credentials, and general configuration.

They are also designed to handle several target hosts.

```bash
git clone https://github.com/MozeBaltyk/mozebaltyk.github.io.git
```

But GitHub.com decided to block password authentication.

So you need to authenticate first with `gh`, which gives you a token as shown below:

```bash
gh auth login

gh auth status -t
github.com
  ✓ Logged in to github.com as MozeBaltyk (~/.config/gh/hosts.yml)
  ✓ Git operations for github.com configured to use ssh protocol.
  ✓ Token: gho_*******************************
  ✓ Token scopes: admin:public_key, gist, read:org, repo

# Then provide the token whenever you want to push...
# The "password" prompt is actually expecting the token.
git push
Username for 'https://github.com': MozeBaltyk
Password for 'https://MozeBaltyk@github.com':
Enumerating objects: 21, done.
Counting objects: 100% (21/21), done.
Delta compression using up to 8 threads
Compressing objects: 100% (10/10), done.
Writing objects: 100% (11/11), 1.44 KiB | 736.00 KiB/s, done.
Total 11 (delta 7), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (7/7), completed with 7 local objects.
remote: This repository moved. Please use the new location:
remote:   https://github.com/MozeBaltyk/mozebaltyk.github.io.git
To https://github.com/mozebaltyk/mozebaltyk.github.io.git
   26a5e21b..ab53b64f  main -> main
```

So here comes the choice.

Either you set the username and token in the `.git/config` as shown below:

```bash
# Connect with token
git config --global url."https://${username}:${access_token}@github.com".insteadOf "https://github.com"
```

Or configure Git to use a credential helper, as we will see later.

Note that this only concerns the HTTPS protocol.

Obviously, SSH authentication relies on SSH keys.

Using a provider CLI such as `gh` has the advantage of centralizing repository credentials.

```bash
# Cloning with GH
# Usually SSH is the default protocol in ~/.config/gh/config.yml
gh repo clone MozeBaltyk/MozeBaltyk

# If you target a specific GitHub host:
GH_HOST=github.example.com gh repo clone MozeBaltyk/MozeBaltyk

# Cloning through HTTPS is also possible:
gh repo clone https://github.com/MozeBaltyk/mozebaltyk.github.io.git

# Same as above using HTTPS
gh repo clone git+https://github.com/MozeBaltyk/MozeBaltyk.git
```

The logic is exactly the same with `glab`, the CLI for GitLab.

The problem here is that `git pull` and `git push` do not automatically use the authentication configured through `gh auth login`.

So you need to configure a helper in your Git configuration.

## Credential Helper

Here comes the **Git Credential Helper**.

The principle is quite simple: Git itself does not really want to know how your credentials are stored.

Instead, Git can delegate this job to an external *credential helper*.

When Git needs to authenticate against an HTTPS remote, it basically asks the helper:

> "Do you have credentials for this host?"

The helper can retrieve them from a password manager, the operating system keyring, or another CLI such as `gh`.

You can check which helper is currently configured with:

```bash
git config --show-origin --get-all credential.helper
```

Git provides some simple helpers itself.

For example:

```bash
# Keep credentials temporarily in memory
git config --global credential.helper cache

# Store credentials on disk
git config --global credential.helper store
```

Be careful with the second one: `store` saves credentials unencrypted on disk.

It works, but this is probably not what you want for a Personal Access Token.

On a desktop, another possibility is to use a credential manager integrated with your operating system.

But in my case, I am also interested in something that works nicely on a bare Linux host, so adding another desktop-oriented credential manager is not necessarily what I want.

### And what about `gh`?

This is where it becomes interesting.

After:

```bash
gh auth login
```

the GitHub CLI already knows how to authenticate against GitHub.

But `git` and `gh` are still two different programs.

Having valid authentication inside `gh` does not magically mean that Git will use it.

Fortunately, `gh` can configure itself as a Git credential helper:

```bash
gh auth setup-git
```

After that, checking the Git configuration should show something related to `gh`:

```bash
git config --show-origin --get-all credential.helper
```

The idea is then:

```text
git push
   |
    +--> Git needs HTTPS credentials
             |
              +--> credential.helper
                        |
                         +--> gh auth git-credential
                                   |
                                    +--> GitHub token
```

So `git` remains Git.

`gh` remains the GitHub CLI.

The credential helper is simply the bridge between the two when authentication is required.

This distinction is important because the provider CLI does not replace Git.

`gh` stores its own authentication, while `gh auth setup-git` explicitly configures Git to use `gh` as its credential helper.

I hope it is clearer now.

`gh repo clone`, for example, is convenient, but behind the scenes we still end up with a perfectly normal Git repository that can be manipulated with:

```bash
git fetch
git pull
git commit
git push
```

And obviously, GitLab follows the same general principle with its own tooling.

## Switching an existing repository from HTTPS to SSH

But the best option is still to switch to SSH, **if you can use it**.

If an existing repository was cloned using HTTPS:

```bash
git remote -v

origin  https://github.com/MozeBaltyk/Colt.git (fetch)
origin  https://github.com/MozeBaltyk/Colt.git (push)
```

there is no need to clone everything again.

Just change the remote:

```bash
git remote set-url origin git@github.com:MozeBaltyk/Colt.git
```

And check it:

```bash
git remote -v

origin  git@github.com:MozeBaltyk/Colt.git (fetch)
origin  git@github.com:MozeBaltyk/Colt.git (push)
```

From this point on, `git pull` and `git push` will use SSH authentication instead of HTTPS authentication.

Of course, this assumes that your SSH key is correctly configured and registered with the provider.

## HTTPS or SSH?

So, finally, which one should we use?

There is no universal answer.

SSH is very convenient for developers.

Once the SSH key and `ssh-agent` are properly configured, there is usually nothing more to provide when pushing or pulling repositories.

HTTPS has another advantage: port `443` is almost universally available, while SSH normally uses port `22`, which may be blocked on corporate networks, proxies, or restricted environments.

And HTTPS authentication with tokens is perfectly valid too.

The annoying part is mostly deciding **who is going to manage this token**.

This is precisely where credential helpers become useful.

So we basically have:

```text
                    Git
                     |
           +----------+----------+
           |                     |
         HTTPS                  SSH
           |                     |
  Credential Helper         SSH Agent / Key
          |
     +-----+------+
     |            |
     gh       Credential
              Manager
```

And then, on top of Git, we have the provider-specific tools:

```text
GitHub  -> gh
GitLab  -> glab
```

They provide additional operations that do not belong to Git itself: creating repositories, opening pull requests or merge requests, managing issues, releases, CI pipelines, and so on.

## So where is the problem?

As you have seen, we have to deal with several providers, sometimes a large number of repositories, all of them potentially using different protocols and authentication systems.

To manage all this, you have to juggle between the `git` command, which remains the standard, and provider CLIs such as `gh`, `glab` or `tea` for advanced or provider-specific operations.

Add to this credential helpers, SSH configurations, several identities, Personal Access Tokens, on-premise GitLab instances, and independent tools designed to manage large numbers of repositories...

Something apparently simple can quickly become confusing.

And this brings me back to my initial problem.

I just wanted my commits to use the correct identity.

But behind this small mistake, there are actually several different questions:

* **Who am I in my commits?** → `user.name` and `user.email`
* **Where is my repository hosted?** → `remote.origin.url`
* **Which protocol am I using?** → HTTPS or SSH
* **How does Git authenticate me?** → credential helper, token, or SSH key
* **How do I interact with provider-specific features?** → `gh`, `glab`, `tea` or another provider CLI

Those concepts are related, but they are not the same thing.

And I think this is exactly why I ended up writing this article from what was, initially, just a simple Git configuration mistake.

