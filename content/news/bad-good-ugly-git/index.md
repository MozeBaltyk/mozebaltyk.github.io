---
# type: docs 
title: The Bad, the Good and the Ugly Git
date: 2023-08-21T03:48:10+02:00
featured: true
draft: true
comment: true
toc: true
reward: true
pinned: false
carousel: true
series:
  - News
categories:
  - Articles
tags:
  - Git
  - Dev
authors:
  - mozebaltyk
images: [./bad-good-ugly-git/carousel.webp]
---

When it come about IT, git is impossible to be ignore... even for infrastructure guys!

<!--more-->



## The bad Surprise

Few days ago, I was wondering why my commits are not counted in my Github Activity Dashboard after a good day of pushing code...

After a quick investigation, I notice that in my project directory `git config user.name` and `git config user.email` are not set.

I go in Github to checks my last commit, actually it's right my push was done with the `git config --global user.name`.

Not a big deal, but this reveal my name when I would rather appreciate to stay anonymous (just a personnal choice).


## A good Solution

I developed a while ago, a tools name [AnsiColt](https://github.com/MozeBaltyk/AnsiColt) to handle the creation of Ansible Collections and manage the diverses projects that I maintain through all my repositories which are divided between Github and GitLab repositories.

One of my hassle is that I am involved in projects stored on diverse SVC as Github or Gitlab. During cloning process, I did not immediatly set the user individually for each projects, so instead of, it was reling on the global config.

Here is the joy of coding, Continously Integration and the good opportunity to kickstart my blog on some banal stories...


## And an Opportunity...

Let's make a small reminder on some basics about git! There are plenty of article, tutorials on the net but this article is going to be my personnal notes on the topics.




## Git with a Github projects

As you probably know, there is three method to connect to a github project with git, SSH, HTTPS and gh. 

SSH will go through port 22. This make look obvious way to go but sometime in your company and specially if you work on a VPN, the port 22 will be block to outbound network.

HTTPS, ok but Github.com decided to block password method. So you will need to initiate a connexion first with GH 

```bash
gh auth login 

gh auth status -t 
github.com
  ✓ Logged in to github.com as MozeBaltyk (~/.config/gh/hosts.yml)
  ✓ Git operations for github.com configured to use ssh protocol.
  ✓ Token: gho_*******************************
  ✓ Token scopes: admin:public_key, gist, read:org, repo

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

But the best is to switch to SSH (if you can) which allow you to set a ssh key. So if you need to switch from HTTPS to SSH

```bash
# at project level
git remote set-url origin git@github.com:MozeBaltyk/abc.git

# in the project's .git/config, then you should have:
[remote "origin"]
        url = git@github.com:MozeBaltyk/mozebaltyk.github.io.git

# at the global level
git config --global url.ssh://git@github.com/.insteadOf https://github.com/
```

Then configure which ssh key to use for Github in $HOME/.ssh/config (create directory/file if necessary)
```bash
# Github
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
```
