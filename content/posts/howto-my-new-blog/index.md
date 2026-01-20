---
title: "🔭 My New Blog"
description: "Sometimes in life, you need to upgrade. This article walks through the new version of my blog and the discoveries that came with it."
date: 2026-01-10T00:35:41+01:00
draft: false
noindex: false
featured: true
pinned: true
comment: true
toc: true
reward: true
carousel: true
series:
  - Posts
categories:
  - Tutorials
tags:
  - Hugo
  - Git
  - Blog
images:
  - ./carousel/howto-my-new-blog.jpg
authors:
  - mozebaltyk
sidebar: false
---

## Intro

I used to have a blog, but it was running on a theme that was becoming less and less maintained. Eventually, the moment had to come: burn it down and start again from scratch.

Starting fresh felt like the right decision — not just technically, but also as an opportunity to refactor and polish my blog.

## On The Value of Blogging.

This blog exists as a place to think slowly.

Most technical work is ephemeral: incidents fade, decisions are forgotten,
and lessons learned are rarely written down. Blogging is my way of pushing
back against that.

I just want to write my thoughs and continue them later on. There is no schedule. 
Some posts may be rough or unfinish. If these notes help someone else along the way, 
that’s a bonus — but not the objective.

## The Tech choice 

For this new iteration of my blog, I stay on **Hugo** with the
**HBStack theme cards**, deployed on **GitHub Pages**. 

It's an old and eproved receipe.

### Why Hugo?

Hugo is a fast, opinionated static site generator that focuses on content first. 

Once generated, the site is just plain HTML, CSS, and JavaScript —
easy to host, easy to secure, and extremely fast.

For me, Hugo offers:
- Excellent performance
- No runtime dependencies
- A simple content workflow
- Long-term stability
- Some Fun in customization (with widget or shortcode)

### Why HBStack and its themes?

HBStack builds on top of Hugo using **modules**, offering a flexible and well-structured ecosystem of themes and extensions.

What really sold me was the availability of **hooks**, which allow deep customization without forking or hacking the theme itself (js,css or html).

Some HBStack features I consider essential for my blog:

- Post and documentation layouts
- Sidebar and table of contents (TOC)
- Emoji and Bootstrap icon support
- Notification badge for new articles
- Customization hooks
- Syntax highlighting
- Comment system (Giscus, backed by GitHub)
- Light / Dark mode
- Search index

### Why GitHub Pages?

GitHub Pages provides a simple, reliable hosting solution for static sites.
Combined with Hugo, it allows me to:
- Host the site for free
- Version content alongside code
- Deploy automatically via GitHub Actions
- Avoid server maintenance entirely

## Start from Scratch 

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

## Update Hugo modules

```bash
hugo mod get -u ./... && hugo mod tidy

npm update

npm ci
```

## Hugo - some Keys Concepts 

First - Hugo behavior is *format-agnostic configuration*, it matches all config files (`.yaml, .yml, .json, .toml` all work from `./data` or `./config`)

Second - In Hugo, everything is a page. 

Third - Folder names under `content/` define sections. Each section can have its own templates.

🔑 Front Matter is the page metadata which strongly influences rendering and behavior.

```md
---
title: "My Post"
date: 2026-01-01
draft: false
tags: ["hugo", "static-site"]
---
```

🔑 Hugo Pipes:
- Asset processing (SCSS → CSS)
- Minification, fingerprinting
- JS bundling
- Cache-friendly builds

## Hugo Structure

```txt
├── archetypes          # Front matter templates used by `hugo new`
├── assets              # Source files processed by Hugo Pipes (SCSS, JS, images)
├── config              # Site configuration (baseURL, params, menus, languages)
├── content             # Markdown content; structure defines URLs
│   ├── _index.en.md    # Section list page
│   ├── categories
│   ├── docs
│   └── posts
├── data                # Global data files (YAML/TOML/JSON) accessible in templates
├── layouts             # HTML templates
│   ├── _default        # Fallback templates (single, list, baseof)
│   ├── partials        # Reusable HTML components
│   └── shortcodes      # Template logic callable from Markdown
├── public              # Generated static site (build output)
└── static              # Static files copied directly to public/
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
    brightness: 10
    modern_format: webp
```

then put images in `assets\images\background.jpg`

* To organize menu and add icons

Either define in `./config/_default/menus.en.yaml`:

```md
main:
  - identifier: navigate
    name: Navigate
    weight: 9
    params:
      icon:
        vendor: bootstrap
        name: signpost-split
        color: "#fd7e14"
```

then you can defined the children like `./content/categories/_index.en.md` with :

```md
---
title: Categories
menu:
  main:
    parent: navigate
    params:
      icon:
        vendor: bs
        name: folder
        color: orange
      description: All of categories.
---
```
or directly from the `index.en.md`:

```md
---
title: Posts
menu:
  main:
    weight: 1
    params:
      icon:
        vendor: bs
        name: body-text
        color: "#20c997"
      description: Some posts on IT topics.
---
```

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

## The Taxonomies

Taxonomies give structure to a growing collection of articles.

They allow posts to be categorized, indexed, and connected to one another
beyond simple chronology. Instead of a linear stream, the blog becomes a
graph: topics intersect, ideas resurface, and related articles can be
discovered naturally.

In practice, taxonomies help both the reader and the author. Readers can
navigate by themes rather than dates, while I can spot recurring subjects,
gaps, or patterns in what I write over time.

Used well, taxonomies are not just metadata — they are a lightweight form of
knowledge organization that keeps a blog coherent as it evolves

in `params.yaml`, you can tell sidebar which one to use to propose some switch button:

```yaml
hb:
  blog:
    sidebar:
      taxonomies:
        count: true # whether to show the number of posts associated to the item.
        limit: 10 # the maximum number of the item.
        style: pills # pills, tabs or underline.
        separate: false # whether to separate into mutliple sections.
        authors:
          disable: true # whether to disable this taxonomy.
          weight: 1 # the weight of this taxonomy, lower gets higher priority.
          count: false # override the global count setting.
          limit: 5 # override the global limit setting.
        categories:
          disable: false
          weight: 2
        series:
          disable: false
          weight: 3
        tags:
          disable: false
          weight: 4
          limit: 25
```

# Editing some content

Based on the *Archetypes* that I defined, I can create a new posts :

```bash
hugo new --kind posts posts/my-new-blog.md
```

or docs:

```bash
hugo new --kind docs docs/Devops/IaC/index.md
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

## Shortcodes

HBstack theme provides a bench shortcodes embended in its bootstrap module [here](https://hbstack.dev/docs/content/shortcodes/)

NB: remove the backslash to use those blocks of code.

* Toogle of config files between toml/yaml/json:

```markdown
{{</* bs/config-toggle "params" */>}}
hb:
  blog:
    home:
      pinned_posts_position: list
{{</* /bs/config-toggle */>}}
```
This one is a nice one, since it automaticly create a block of code with 3 tabs to switch between the 3 type of config (TOML/YAML/JSON) like below:

{{< bs/config-toggle "params" >}}
hb:
  blog:
    home:
      pinned_posts_position: list
{{< /bs/config-toggle >}}

* Simple toggle

```markdown
{{</* bs/toggle name=sdk style=pills */>}}

  {{</* bs/toggle-item JS */>}}
    {{</* highlight js */>}}
    console.log('hello world');
    {{</* /highlight */>}}
  {{</* /bs/toggle-item */>}}

  {{</* bs/toggle-item PHP */>}}
    {{</* highlight php */>}}
    echo 'hello world';
    {{</* /highlight */>}}
  {{</* /bs/toggle-item */>}}
  
  {{</* bs/toggle-item Go */>}}
    {{</* highlight go */>}}
    fmt.Println("hello world")
    {{</* /highlight */>}}
  {{</* /bs/toggle-item */>}}

{{</* /bs/toggle */>}}
```

The result:

{{< bs/toggle name=sdk style=pills >}}

  {{< bs/toggle-item JS >}}
    {{< highlight js >}}
    console.log('hello world');
    {{< /highlight >}}
  {{< /bs/toggle-item >}}

  {{< bs/toggle-item PHP >}}
    {{< highlight php >}}
    echo 'hello world';
    {{< /highlight >}}
  {{< /bs/toggle-item >}}
  
  {{< bs/toggle-item Go >}}
    {{< highlight go >}}
    fmt.Println("hello world")
    {{< /highlight >}}
  {{< /bs/toggle-item >}}

{{< /bs/toggle >}}

* Some [Alert banner](https://hugomods.com/bootstrap/alert/) - *primary, secondary, success, danger, warning, info, light, dark* options:

```markdown
{{</* bs/alert info */>}}
{{</* markdownify */>}}
Create a *info* **banner** to inform readers about this syntax and with markdown inside.
{{</* /markdownify */>}}
{{</* /bs/alert */>}}
```

give this effect:

{{< bs/alert info >}}
{{< markdownify >}}
Create a *info* **banner** to inform readers about this syntax and with markdown inside.
{{< /markdownify >}}
{{< /bs/alert >}}

Some other which could be usefull: 

* The [collapse shortcode](https://bootstrap.hugomods.com/docs/collapse/) - show and hidde content: 

* The [Clearfix](https://hugomods.com/bootstrap/clearfix/) - Quickly and easily clear floated content within a container 

## Images

* Featured image:

The first image of the images parameter, usually used for static and external images.

The page image’s resources that naming in pattern `feature*`, such as `feature.png`, `featured-xx.jpg`. The featured image resource will be resized in smaller size, to save user’s and server’s bandwidth.

* Image used in article goes in `static/<article-filename>/image.jpg`

## Deployment

On this side as well, there is improvment since a new docker images with all dependencies is provided on docker.io. Which is the local testing of the blog and reproductibilty.  

But the github workflows deployment in `.github/workflows/gh-pages.yaml` with a *build* job and a "deploy" job which trigger when I push on main.

## What’s next?

At this stage, what could you do more: 

* Share your website with the HB to showcase that you are using HB theme on their hompage.
  [doc](https://hbstack.dev/sites/)

* Create custom widget like in this [article](https://mozebaltyk.github.io/posts/howto-create-custom-widget)

* Check the uptime of your site with a simple [github action](https://github.com/upptime/upptime)

* Auto-update with `renovate.json`

* Write your docs with Obsidian: [Here](https://github.com/orgs/hbstack/discussions/92) are some elements about how to set it correctly.

* Dive into [shortcodes](https://mozebaltyk.github.io/posts/howto-write-hugo-shortcode) and write some custom.

* Polish and customize [RSS feed](https://mozebaltyk.github.io/posts/howto-customize-feed-rss/) 