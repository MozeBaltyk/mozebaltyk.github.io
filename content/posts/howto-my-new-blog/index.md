---
title: "🔭 My New Blog"
description: "Sometime in life, you need to upgrade..."
date: 2026-01-10T00:35:41+01:00
draft: true
noindex: false
featured: true
pinned: true
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
* Search index
* Post and docs layout
* Sidebar and TOC (table of content)
* Handle Emoji and Bootstrap icons
* Ring bell in menu for new articles
* Hooks to customize 
* Syntax Highlighting
* Comments Panels (giscuss module from Github)
* Light/Dark mode

## Start from scratch 

It's always better. Even though, I had already a blog, I started from scratch and imported the `content` and `assests` in the new blog to avoid all the assles. 

This maybe repeating the tutorials [here](https://theme-cards.hbstack.dev/docs/install-from-scratch/) but just for the records:

```bash
# install go
sudo apt install golang-go
go version

# install Hugo
HUGO_VERSION="0.148.0"
curl -LJO https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz
tar -xzf hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz
sudo mv hugo /usr/bin/hugo
hugo version

# install nodejs 16 or higher
sudo apt install nodejs npm git
nodejs -v

# install Dart Sass
npm install -g sass
sass --version

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

```yaml
# in ./config/_default/hugo.yaml
baseURL: https://mozebaltyk.github.io/
title: Bałtyk Blog
```

* Change background 

```yaml
# in ./config/_default/params.yaml
hb:
  background_image:
    brightness: 0.3
    modern_format: webp
```

then put images in `assets\images\background.jpg`

* Organize menu and add icons

* Change the *back-to-top* icon

```yaml
# in ./config/_default/params.yaml
hb:
  back_to_top:
    animation: true
    icon_height: 2em
    icon_name: hand-index
    icon_width: 2em
    position_bottom: 1rem
    position_end: 1rem
```

## Organisational choices

The menu

The taxonomies will allow to categories, will help the index and allow to make correlations between articles.

# Manage Images

# Editing some content

Based on the *Archetypes* that I defined, I can create a new posts :

```bash
hugo new --kind posts posts/my-new-blog.md
```

#### A word on giscus

In `./config/_default/params.yaml`, there is giscus blocks config. Giscus is a comments system powered by GitHub Discussions, so the comments left on your articles goes in discussions of your github Pages.  

To do so, you will need to:

* Make your repository public.

* Enable [discussions](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/enabling-or-disabling-github-discussions-for-a-repository) in the project settings.

* Activate [giscus app](https://github.com/apps/giscus) for on your account (you can limit to your blog project)

* Then, giving the URL of your repository

```yaml
hb:
  blog:
    giscus:
      repo: MozeBaltyk/mozebaltyk.github.io
      repo_id: R_kgDOKJSCfA
      category_id: DIC_kwDOKJSCfM4CYvA_
  docs:
    giscus:
      repo: MozeBaltyk/mozebaltyk.github.io
      repo_id: R_kgDOKJSCfA
      category_id: DIC_kwDOKJSCfM4CYvA_
```

On their side, visitors will need a Github account and must authorize the giscus app to post on their behalf using the GitHub OAuth flow.

## Bootstrap module

NB: remove the backslash to use those blocks of code.

* Toogle of config files between toml/yaml/json:

```md
\{\{< bs/config-toggle "params" >\}\}
hb:
  blog:
    home:
      pinned_posts_position: list
\{\{< /bs/config-toggle >\}\}
```
This one is a nice one, since it automaticly create a block of code with 3 tabs to switch between the 3 type of config (TOML/YAML/JSON) like below:

{{< bs/config-toggle "params" >}}
hb:
  blog:
    home:
      pinned_posts_position: list
{{< /bs/config-toggle >}}

* Some banner for info, warning, etc:

```md
\{\{< bs/alert info >\}\}
\{\{< markdownify >\}\}
This is the old version of this blog. But last update of hugo version did not work well so I decided to move on to the hbstack theme. I keep this article since it was the first one of this blog. 
\{\{< /markdownify >\}\}
\{\{< /bs/alert >\}\}
```

give this effect:

{{< bs/alert info >}}
{{< markdownify >}}
Example of informational banner
{{< /markdownify >}}
{{< /bs/alert >}}

Refere to this [doc](https://bootstrap.hugomods.com/docs/collapse/) for all the examples. 

## Deployment

On this side as well, there is improvment since a new docker images with all dependencies is provided on docker.io. Which is the local testing of the blog and reproductibilty.  

But the github workflows deployment in `.github/workflows/gh-pages.yaml` with a *build* job and a "deploy" job which trigger when I push on main.

## Plug it with Obsidian ?

## Bonuses

At this stage, what could you do more: 

* Share your website with the HB to showcase that you are using HB theme on their hompage.
  [doc](https://hbstack.dev/sites/)

* Create custom widget like in this [article](https://mozebaltyk.github.io/posts/howto-create-custom-widget)

* Check the uptime of your site with a simple [github action](https://github.com/upptime/upptime)

* Auto-update with `renovate.json`