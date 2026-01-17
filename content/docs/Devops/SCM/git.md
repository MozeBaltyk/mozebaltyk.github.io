---
date: 2023-08-01T21:00:00+08:00
title: Git
navWeight: 50 # Upper weight gets higher precedence, optional.
nav_icon:
  vendor: bootstrap
  name: git
  color: grey
series:
  - Docs
categories:
  - Devops
tags:
  - Git
---


> GIT is a distributed version control system that was created by Linus Torvalds, the mastermind of Linux itself. It was designed to be a superior version control system to those that were readily available, the two most common of these being CVS and Subversion (SVN).
> Whereas CVS and SVN use the Client/Server model for their systems, GIT operates a little differently. Instead of downloading a project, making changes, and uploading it back to the server, GIT makes the local machine act as a server.
> <cite>[Tecmint](https://www.tecmint.com/install-git-to-create-and-share-your-own-projects-on-github-repository/)</cite>


## The basics

```bash
# Clone an existing Projet: 
git clone https://github.com/MozeBaltyk/bac-a-sable

# Save your changes:
cd bac-a-sable/
touch file.txt
git add bac-a-sable/
git commit -m "start with a verb then on something"
git push origin master

# Not recommand but take everything
git add -A
```

## Branches

```bash
# List local branch
git branch
master
* new_branch

# List remote branch
git branch -r
master
* new_branch

# Switch
git checkout new_branch
Switched to branch 'new_branch'

#Create 
git checkout -b rookSetup
git push --set-upstream origin rookSetup

# Delete 
git branch -D test_branch
Deleted branch test_branch (was 5776472).
git push origin :test_branch

#Merge Branches dev with master
git checkout master 
git merge dev 
```

## Rollback

```bash
#Quit a commit
git rebase --skip
git rebase origin/master

# Rollback a file
git checkout -- filename.yml
```

## Investigate

```bash
git log
git log -p <commit_nbr>
git log --oneline --decorate --graph --all   : Voir en graphes tous les commits 
```

## Resolve conflict

During a push, you realise that someone already pushed, so git ask you to pull first
```bash
AnsiColt git:main ❯ git push
To ssh://github.com/MozeBaltyk/AnsiColt.git
 ! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'ssh://github.com/MozeBaltyk/AnsiColt.git'
hint: Updates were rejected because the remote contains work that you do
hint: not have locally. This is usually caused by another repository pushing
hint: to the same ref. You may want to first integrate the remote changes
hint: (e.g., 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

During pull, it possible you did not set the rebase
```bash
AnsiColt git:main ❯ git pull 
remote: Enumerating objects: 5, done.
remote: Counting objects: 100% (3/3), done.
remote: Total 5 (delta 3), reused 3 (delta 3), pack-reused 2
Unpacking objects: 100% (5/5), 839 bytes | 279.00 KiB/s, done.
From ssh://github.com/MozeBaltyk/AnsiColt
   52a5d9a..38bea24  main       -> origin/main
hint: You have divergent branches and need to specify how to reconcile them.
hint: You can do so by running one of the following commands sometime before
hint: your next pull:
hint:
hint:   git config pull.rebase false  # merge (the default strategy)
hint:   git config pull.rebase true   # rebase
hint:   git config pull.ff only       # fast-forward only
hint:
hint: You can replace "git config" with "git config --global" to set a default
hint: preference for all repositories. You can also pass --rebase, --no-rebase,
hint: or --ff-only on the command line to override the configured default per
hint: invocation.
fatal: Need to specify how to reconcile divergent branches.
```

For me the best is to set it to false, to manually resolved conflit. That's a carefull approach. 
```bash
AnsiColt git:main ❯ git config pull.rebase false
```

The pull will then indicate which files have conflits, so you can take a look and solve those conflits
```bash
AnsiColt git:main ❯ git pull
Auto-merging .github/workflows/ci.yml
CONFLICT (content): Merge conflict in .github/workflows/ci.yml
Automatic merge failed; fix conflicts and then commit the result.

AnsiColt git:main ❯ vi .github/workflows/ci.yml 

AnsiColt git:main ❯ git add -A
AnsiColt git:main ❯ git commit -m "desactivate workflow"
[main 75b47c2] desactivate workflow
AnsiColt git:main ❯ git push
```

## My .gitconfig

Set some usefull aliases inside your `~/.gitconfig`:

```ini
[alias]
    br = branch
    co = checkout
    ci = commit
    st = status

    # pretty and compact log with colours:
    lg = log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'

[color]
    # enable colours for diff, log, etc.
    ui = true
```

## Git submodules

```bash
# Initialisation a new project (here an ansible collection)
git clone https://<username>:<token>@gitlab.example.com/group/namespace.general.git
ansible-galaxy collection init namespace.general
git add -A &&  git commit -m "Initialisation" && git push 

# Add submodules 
git submodule add https://<username>:<token>@gitlab.example.com/group/namespace.another.git
git submodule add https://<username>:<token>@gitlab.example.com/group/namespace.second.git
git add -A &&  git commit -m "Initialisation" && git push 

# Update submodules
cd namespace/general
git pull --recurse-submodules     #Fetch and show if there were changes from submodule
git submodule update --remote --merge
git add -A
git commit -am "message"
git push

# Update to last tag
cd namespace/general/my/submodule
git fetch && git tag | tail -1
git checkout $(git tag | tail -1) 
cd ../..
git add my/submodule
git commit -m "update submodules"
git push

# Remove a submodule
git submodule deinit [submodule-path]
git rm --cached [submodule-path]
rm -rf .git/modules/test
git config --remove-section submodule.test
```
