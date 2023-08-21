---
# type: docs 
title: The Bad, the Good, the Lucky
date: 2023-08-21T03:48:10+02:00
featured: false
draft: true
comment: true
toc: true
reward: true
pinned: false
carousel: false
series:
categories: []
tags: []
images: []
---

Summary.

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
