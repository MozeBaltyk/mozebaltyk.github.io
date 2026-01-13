---
title: "My New Blog"
description: "Sometime in life, you need to upgrade..."
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
  - Tutorials
categories:
  - Posts
tags:
  - Migration
  - Hugo
  - Git
images:
  - ./howto-my-new-blog/carousel.jpg
authors:
  - mozebaltyk
sidebar: false
---

I use to have a blog 

All the good reasons to have a blog...

The benefit of **hbstack** and its' themes ? A bit of history

Some of the HBstack features, I found necessary for my blogs:
* 
* 
* 

## Start from scratch 

It's always better. Even though, I had already a blog, I started from scratch and imported the `content` and `assests` in the new blog to avoid all the assles. 

This maybe repeating the tutorials [here](https://theme-cards.hbstack.dev/docs/install-from-scratch/) but just for the records:

```bash
# install go
# install Hugo
# install nodejs 16 or higher
# install Dart Sass

# clone theme 
git clone --depth 1 https://github.com/hbstack/theme-cards
cp -r theme-cards/exampleSite mysite
cd mysite
sed -i '1s/.*/module github.com\/user\/repo/' go.mod
sed -i '/^replace/d' go.mod

# Install hugo dependencies
npm ci

# Run locally
npm run dev
```

## Tweak the config

* The basics

* Change background 

* Organize menu and add icons

* Change the *back-to-top* icon 



## Organisational choices

The menu

The taxonomies will allow to categories, will help the index and allow to make correlations between articles.

# Manage Images

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

## Bonuses

At this stage, what could you do more: 

* Share your website with the HB to showcase that you are using HB theme on their hompage.
  [doc](https://hbstack.dev/sites/)

* Create custom widget like in this [article](https://mozebaltyk.github.io/posts/howto-create-custom-widget)