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
  - Devops
categories:
  - Posts
tags:
  - Git
  - Devops
authors:
  - mozebaltyk
images: [./bad-good-ugly-git/carousel.webp]
sidebar: false
---

When it come about IT, git cannot to be ignore... even for an infrastructure guys!

<!--more-->

## The bad Surprise

Few days ago, I was wondering why my commits are not counted in my Github Activity Dashboard after a good day of pushing code...
After a quick investigation, I notice that in my project directory `git config user.name` and `git config user.email` are not set.
I go in Github to checks my last commit, actually it's right my push was done with the `git config --global user.name`.
Not a big deal, but this reveal my name when I would rather appreciate to stay anonymous (just a personnal choice).


## A good Solution

I developed a while ago, a tools name [AnsiColt](https://github.com/MozeBaltyk/AnsiColt) (Which is a *retired* projects by now) to handle the creation of Ansible Collections and manage the diverses projects that I maintain through all my repositories which are divided between Github and GitLab repositories.

One of my hassle is that I am involved in projects stored on diverse SVC as Github or Gitlab. During cloning process, I did not immediatly set the user individually for each projects, so instead of, it was reling on the global config.

Here is the joy of coding, Continously Integration and the good opportunity to kickstart my blog on some banal stories...


## And an Opportunity...

Let's make a small reminder on some basics about git! There are plenty of article, tutorials on the Net but this article is going to be my personnal notes on the topics. 

Each project local or hosted have a hidden directory `.git` with its own `.git/config` but you also got in your home directory an `.gitconfig` which is global. 
So when in the `.git/config` of your project, it does not find the user and email, it get the global one from `~/.gitconfig` or ask you to set it up. This can become relevant when you are handling a lot of projects between different repositories publics and on premise. 

So usually, you will have to setup: 

```bash
# Setup
cd ~/my_project
git config user.name "john.smith"
git config user.email "john.smith@example.com"

# Check
git config user.name
git config user.email

git config --global user.name
git config --global user.email
```

## Git with a Github projects

As you probably know, there is three method to connect to a github project with git, SSH, HTTPS and gh. 

SSH will go through port 22. This make look obvious way to go but sometime in your company and specially if you work on a VPN, the port 22 will be block to outbound network.

HTTPS have one advantage, it is that you will probably always be able to clone. 

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

This one used to work but I think not anymore (I should try it)
```bash
#Connect with token 
git config --global url."https://${username}:${access_token}@github.com".insteadOf "https://github.com"
```

But the best is to switch to SSH (if you can) which allow you to set a ssh key. So if you need to switch from HTTPS to SSH

```bash
# at project level
git remote set-url origin git@github.com:MozeBaltyk/abc.git

# in the project's .git/config, then you should have:
[remote "origin"]
        url = git@github.com:MozeBaltyk/mozebaltyk.github.io.git

# at the global level
git config --global url.ssh://git@github.com/.insteadOf https://github.com/

# or local
cd my_project
git config url.ssh://git@github.com/.insteadOf https://github.com/
```

Then configure which ssh key to use for Github in `$HOME/.ssh/config` (create directory/file if necessary)
```bash
# Github
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
```

The top is to use `gh` which is the github-cli tools for handling github projects. So it's noticable that github prefers SSH protocol over HTTPS.

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

## Now AnsiColt

Here come the time to improve a bit [AnsiColt](https://github.com/MozeBaltyk/AnsiColt) with what I have learnt. So when I start or clone a project either in Gitlab or Github, I make sure that `git config -local user.name` and `git config -local user.email` are confgiure for the project. To do so, I need to get the info from somewhere... 

* for Github  `~/.config/gh/hosts.yml`:
```yaml
github.com:
  oauth_token: gho_******************
  user: MozeBaltyk
  git_protocol: ssh
  email: john@example.com
``` 

* for Gitlab have one config file `~/.config/glab-cli/config.yml`:
```yaml
hosts:
    gitlab.example.com:
        token: **************
        api_host: gitlab.example.com
        git_protocol: https
        api_protocol: https
        user: john
        email: john.doe@gg.com
``` 

By default email value does not exist on those config files. so If I do not find it, I will add it. Doing this, allow me to get the settings for all future repos cloning or creations.   


## Bonus point 

For those who read till the end, [gitmoji](https://gitmoji.dev/) is an Art. 