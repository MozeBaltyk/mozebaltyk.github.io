---
title: "My New Blog"
description: "Sometime, you need to upgrade..."
date: 2026-01-10T00:35:41+01:00
draft: true
noindex: false
featured: false
pinned: false
comment: true
toc: true
reward: true
carousel: true
series: 
  - Devops
categories:
  - Posts
tags:
  - Migration
images:
#  - images/...
authors:
  - mozebaltyk
sidebar: false
---

I use to have a blog 

All the good reasons to have a blog...

The benefit of **hbstack** and its' themes ? A bit of history


## Start from scratch 

It's always better. Even though, I had already a blog, I started from scratch and imported the `content` and `assests` in the new blog to avoid all the assles. 



## Tweak the config


## Organisational choices

The menu

The taxonomies will allow to categories, will help the index and allow to make correlations between articles.


# Editing some content

Based on the *Archetypes* that I defined, I can create a new posts :

```bash
hugo new --kind posts posts/my-new-blog.md
```

## Code blocks

* Toogle of config files (toml/yaml/json):

```md
{{< bs/config-toggle "params" >}}
hb:
  blog:
    home:
      pinned_posts_position: list
{{< /bs/config-toggle >}}
```

* Some banner for info, warning, etc:

```md
{{< bs/alert info >}}
{{< markdownify >}}
This is the old version of this blog. But last update of hugo version did not work well so I decided to move on to the hbstack theme. I keep this article since it was the first one of this blog. 
{{< /markdownify >}}
{{< /bs/alert >}}
```


## Deployment

On this side as well, there is improvment since a new docker images with all dependencies is provided on docker.io. Which is the local testing of the blog and reproductibilty.  

## Plug it with Obsidian ?