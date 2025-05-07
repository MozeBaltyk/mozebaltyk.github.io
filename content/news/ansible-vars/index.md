---
type: news 
title: 💫 My thoughs about Ansible Collections and Variables
date: 2023-08-22T03:48:10+02:00
featured: true
draft: true
comment: true
toc: true
reward: true
pinned: false
carousel: true
series:
  - Articles
categories:
  - Blog
tags:
  - Ansible
  - Devops
authors:
  - mozebaltyk
images: [./ansible-vars/carousel.webp]
---

When it came about Ansible collection and Variables...

<!--more-->

## First install ansible-dev-tools

On Ubuntu 24.04 LTS, the new version of python does not allow to install out of *venv* due to the new *external-managed-environment*, but we need at user level command.

```bash
python3 -m pip install ansible-navigator --user
error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try apt install
    python3-xyz, where xyz is the package you are trying to
    install.

    If you wish to install a non-Debian-packaged Python package,
    create a virtual environment using python3 -m venv path/to/venv.
    Then use path/to/venv/bin/python and path/to/venv/bin/pip. Make
    sure you have python3-full installed.

    If you wish to install a non-Debian packaged Python application,
    it may be easiest to use pipx install xyz, which will manage a
    virtual environment for you. Make sure you have pipx installed.

    See /usr/share/doc/python3.12/README.venv for more information.

note: If you believe this is a mistake, please contact your Python installation or OS distribution provider. You can override this, at the risk of breaking your Python installation or OS, by passing --break-system-packages.
hint: See PEP 668 for the detailed specification.
```


So `uv` is the way:

```bash
uv tool install ansible-dev-tools
uv tool list
```

Eventually add it to your `.profile` :

```sh
export PATH=$PATH:$HOME/.local/bin:$HOME/.local/share/uv/tools/ansible-dev-tools/bin/
```

## The Collection structure 


## Build an EE container


## Use Ansible-galaxy

* Token for a private project in Galaxy 
ansible-galaxy role install --token $GITLAB_TOKEN -r requirements.yml --force

* Gitlab Token 
git clone https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.example.com/<namespace>/<project>