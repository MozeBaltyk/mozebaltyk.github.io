---
title: 👺 The Bad, the Good and the Ugly Git
date: 2024-10-28T03:48:10+02:00
noindex: false
featured: true
draft: false
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
  - Devops
authors:
  - mozebaltyk
images: 
  - ./carousel/bad-good-ugly-git.jpg
sidebar: false
---

When it come about IT, git cannot to be ignore... even for an infrastructure guys!

<!--more-->

## The bad Surprise

Few days ago, I was wondering why my commits are not counted in my Github Activity Dashboard after a good day of pushing code...
After a quick investigation, I notice that in my project directory `git config user.name` and `git config user.email` are not set.
I went to checks on Github my last commit, actually it's right my push was done with the `git config --global user.name`.
Not a big deal, but this reveal my name when I would rather appreciate to stay anonymous (just a personnal choice).


## A good Solution

I developed a while ago, a tools name [AnsiColt](https://github.com/MozeBaltyk/AnsiColt) (Which is a *retired* projects by now) to handle the creation of Ansible Collections and manage the diverses projects that I maintain through all my repositories which are divided between Github and GitLab repositories.

One of my hassle is that I am involved in projects stored on diverse SVC as Github or Gitlab. During cloning process, I did not immediatly set the user individually for each projects, so instead of, it was reling on the global config.

Here is the joy of coding, Continously Integration and the good opportunity to kickstart my blog on some banal stories...


## And an Opportunity...

Let's make a small reminder on some basics about Git! There are plenty of articles and tutorials on the Net, but this article is going to be my personal notes on the topic.

Each local project has a hidden directory `.git` with its own `.git/config`, but you also have an `.gitconfig` in your home directory, which is the global configuration applying to all your Git repositories.

So when Git does not find the user and email in the `.git/config` of your project, it gets them from the global `~/.gitconfig`, if they are defined there. This can become relevant when you are handling a lot of projects between public repositories, personal projects and on-premise repositories.

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

This works perfectly well, but it also means that I have to remember to do it **each time I clone a new repository**.

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

No need anymore to remember:

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

Or display all the configuration and its origins:

```bash
git config --list --show-origin
```

This is particularly useful with `includeIf`, because several configuration files can now participate in the final Git configuration.

### Local, global... and conditional

So finally, my initial mistake was not really a Git problem. Git did exactly what I asked it to do: no identity was configured locally, so it fell back to the identity from my global configuration.

The problem was rather how I organized my configuration.

Setting `user.name` and `user.email` locally works when you have a few repositories. But when you start juggling between personal projects, public projects, company repositories and different Git providers, `includeIf` becomes much more interesting.

And there is another important distinction here: `user.name` and `user.email` define **the identity written into my commits**. They do not define **how I authenticate against GitHub or GitLab**.

That is another story involving HTTPS tokens, SSH keys and credential helpers...


## Git authentication

On Public repository, you will be allowed to clone without login but when it came to push to the remote origin, git will need an authentication system.

* HTTPS protocol, (usually the default choice)

in `.git/config`, by default you will find. 

```cfg
[remote "origin"]
        url = https://github.com/MozeBaltyk/Colt.git
```

But it will request an authentification everytime you push, so came the Oauth2 token. 

```cfg
[remote "origin"]
        url = https://oauth2:xxxxxxxxxxxx@github.com/MozeBaltyk/Colt.git
```

you can set it with a command line at global level, if you don't want to edit each `.git/config` of each repository.

```bash
#Connect with token 
git config --global url."https://${username}:${access_token}@github.com".insteadOf "https://github.com"
```

* SSH protocol with 

if the ssh pub key is set on Github and define your `~/.ssh/config` like:

```cfg
 ~/.ssh/config
Host github.com
  HostName github.com
  User MozeBaltyk
  IdentityFile ~/.ssh/ed25519
```

Then in `.git/config` of your project set remote orgin using `git` protocol as below:

```cfg 
[remote "origin"]
        url =  git@github.com:MozeBaltyk/Colt.git
```

In fact, it's often forgotten, this model is available on a bare linux host. Everyone can use git with a local ssh server.

One word on the choice of the protocol. It may sound obvious, but SSH usually goes through port 22. Some companies will block outgoing connections to port 22, so in this sense HTTPS is more standard and easier to use through corporate networks. GitHub does not allow password authentication for Git operations over HTTPS anymore, but you can use a **Personal Access Token** instead. The question then becomes how and where to securely store this token.



## The CLI providers tools, gh or glab

What we saw earlier is the default git command to manage your projects. But you are limited to git actions... and excluded from the providers actions like creating issues, opening pull request, etc.

The providers CLI, will also allow to choose between HTTPS or SSH protocol. Usually those provider use `~/.config/` to store the protocol, credentials, and general config. There also made to handle several target hosts.

```bash 
git clone https://github.com/MozeBaltyk/mozebaltyk.github.io.git
```

Ok but Github.com decided to block password method. So you will need to initiate a connexion first with GH so you can get a token as describe below:

```bash
gh auth login 

gh auth status -t 
github.com
  ✓ Logged in to github.com as MozeBaltyk (~/.config/gh/hosts.yml)
  ✓ Git operations for github.com configured to use ssh protocol.
  ✓ Token: gho_*******************************
  ✓ Token scopes: admin:public_key, gist, read:org, repo

# And give the token everytime, you want to push... (Password is not what you think, it's expecting the Token)
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

So here come to choice, either you set the username and token in the `.git/config` like below:
```bash
#Connect with token 
git config --global url."https://${username}:${access_token}@github.com".insteadOf "https://github.com"
```

Or configure git local config to use a credential helper (As we will see later). Note that concern only HTTPS protocol. Obviously SSH protocol will rely on SSH keys.  

Using the provider CLI like `gh` will bring the advantage to manage in centralized way your reposistory credentials.

```bash
# Cloning with GH  (usually SSH as default protocol in your ~/.config/gh/config.yml):
gh repo clone MozeBaltyk/MozeBaltyk

# If you target a specific Github:
GH_HOST=github.example.com gh repo clone MozeBaltyk/MozeBaltyk

# gh clone https is also possible:
gh repo clone https://github.com/MozeBaltyk/mozebaltyk.github.io.git

#Same as above in https
gh repo clone git+https://github.com/MozeBaltyk/MozeBaltyk.git
```

The logic is exactly the same with glab-cli, the CLI version for GitLab. 

The problem here, is that to `git pull` and `git push`, will not use the `gh auth login`. So you will need to set an helper in your git config. 

## Credential Helper

Here comes the **Git Credential Helper**.

The principle is quite simple: Git itself does not really want to know how your credentials are stored. Instead, Git can delegate this job to an external *credential helper*.

When Git needs to authenticate against an HTTPS remote, it basically asks the helper:

> "Do you have credentials for this host?"

The helper can retrieve them from a password manager, the operating system keyring, or another CLI such as `gh`.

You can check which helper is currently configured with:

```bash
git config --show-origin --get-all credential.helper
```

Git provides some simple helpers itself. For example:

```bash
# Keep credentials temporarily in memory
git config --global credential.helper cache

# Store credentials on disk
git config --global credential.helper store
```

Be careful with the second one: `store` saves the credentials unencrypted on disk. It works, but this is probably not what you want for a Personal Access Token.

On a desktop, another possibility is to use a credential manager integrated with your operating system. But in my case, I am also interested in something which works nicely on a bare Linux host, so adding another desktop-oriented credential manager is not necessarily what I want.

### And what about `gh`?

This is where it becomes interesting.

After:

```bash
gh auth login
```

the GitHub CLI already knows how to authenticate against GitHub. But `git` and `gh` are still two different programs.

Having a valid authentication inside `gh` does not magically mean that Git will use it.

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

So `git` remains Git. `gh` remains the GitHub CLI. The credential helper is simply the bridge between both when authentication is required.

This distinction is important because the provider CLI does not replace Git. `gh` stores its own authentication, while `gh auth setup-git` explicitly configures Git to use `gh` as its credential helper. Hope it's clear now. 

`gh repo clone`, for example, is convenient, but behind the scene we still end up with a perfectly normal Git repository which can be manipulated with:

```bash
git fetch
git pull
git commit
git push
```

And obviously, GitLab follows the same general principle with its own tooling.

## Switching an existing repository from HTTPS to SSH

But the best is still to switch to SSH, **if you can use it**.

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

From this point, `git pull` and `git push` will use SSH authentication instead of HTTPS authentication.

Of course this assumes that your SSH key is correctly configured and registered on the provider.

## HTTPS or SSH?

So finally, which one should we use?

There is no universal answer.

SSH is very convenient for developers. Once the SSH key and `ssh-agent` are properly configured, there is usually nothing more to provide when pushing or pulling repositories.

HTTPS has another advantage: port `443` is almost universally available, while SSH normally uses port `22`, which can be blocked on corporate networks, proxies or restricted environments.

And HTTPS authentication with tokens is perfectly valid too. The annoying part is mostly deciding **who is going to manage this token**.

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

And then on top of Git, we have the provider-specific tools:

```text
GitHub  -> gh
GitLab  -> glab
```

They provide additional operations which do not belong to Git itself: creating repositories, opening pull requests / merge requests, managing issues, releases, CI pipelines, and so on.

## A word on independent projects

Of course, I am not the first one to face the problem of managing repositories spread across different providers. There are several independent projects trying to put another abstraction layer on top of Git and the provider APIs.

[Hyperforge](https://github.com/hypermemetic-ai/hyperforge) takes a declarative approach to multi-forge repository management. It can manage repositories across GitHub, GitLab and Codeberg, with the idea of having an origin and eventually mirrors on other forges.

[Coco](https://coco.griffen.codes/docs/getting-started) goes further than repository management. It provides a Git terminal workstation with AI-assisted commits, reviews and changelogs, but also abstracts some forge operations. It detects the remote provider and can use `gh` for GitHub, `glab` for GitLab, or APIs for some other forges.

[Gitfleet](https://github.com/airscripts/gitfleet) tries to provide a provider-neutral CLI for GitHub and GitLab. Instead of remembering which command belongs to `gh` or `glab`, the idea is to expose a common vocabulary for repositories, issues, pipelines, releases and other provider operations.

[RepoBee](https://github.com/repobee/repobee) is another interesting project, although with a more specific use case. It was designed for teachers and teaching assistants managing a large number of student repositories, and supports GitHub, GitLab and Gitea. Still, the underlying problem is familiar: doing the same operations over tens or hundreds of repositories without having to handle each one manually.

Those projects have different goals, but they illustrate the same thing: as soon as you start working with several Git providers and a large number of repositories, `git` alone is no longer covering the whole workflow.

And this is where things become interesting... because should we use `git`, `gh`, `glab`, or put yet another abstraction layer on top of all of them?


## So where is the problem?

As you saw, we have to deal with several providers, sometimes a big amount of repositories, all of them potentially using different protocols and authentication systems.

To manage all this, you have to juggle between the `git` command, which remains the standard, and provider CLIs such as `gh` and `glab` for advanced or provider-specific operations.

Add to this credential helpers, SSH configurations, several identities, Personal Access Tokens, on-premise GitLab instances and some independent tools made to manage a large number of repositories... and something apparently simple can quickly become confusing.

And this brings me back to my initial problem.

I just wanted my commits to use the correct identity.

But behind this small mistake there are actually several different questions:

* **Who am I in my commits?** → `user.name` and `user.email`
* **Where is my repository hosted?** → `remote.origin.url`
* **Which protocol am I using?** → HTTPS or SSH
* **How does Git authenticate me?** → credential helper, token or SSH key
* **How do I interact with provider-specific features?** → `gh`, `glab`, or another provider CLI

Those concepts are related, but they are not the same thing.

And I think this is exactly why I ended up writing this article from what was, initially, just a banal Git configuration mistake.