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


* Token for a private project in Galaxy 
ansible-galaxy role install --token $GITLAB_TOKEN -r requirements.yml --force

* Gitlab Token 
git clone https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.example.com/<namespace>/<project>