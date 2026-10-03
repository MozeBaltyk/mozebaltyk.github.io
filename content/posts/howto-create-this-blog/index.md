---
title: 🌌 How I Created This Blog
description: "The beginning of this blog — its first version."
date: 2023-10-01T02:59:46+02:00
noindex: false
featured: false
draft: false
comment: true
toc: true
reward: true
pinned: false
carousel: true
series:
  - Building This Blog
categories:
  - Tutorials
tags:
  - Hugo
  - Git
authors:
  - mozebaltyk
images:
  - carousel/howto-create-this-blog.webp
sidebar: false
---

{{< bs/alert info >}}
{{< markdownify >}}

This article describes the **old version of this blog**.

After a Hugo upgrade caused problems with the original theme, I eventually moved to HBStack.

I decided to keep this article because it was the very first post published on this blog and documents how the project originally started.

{{< /markdownify >}}
{{< /bs/alert >}}

When I first considered creating a blog, I went through the usual questions:

Why would I spend precious hours of my life writing something that perhaps nobody will ever read?

This article contains my thoughts about that question, what I wanted from a blog, and what I learned while building the first version of this site.

<!--more-->

## My reflections on the topic

In short, I went through a few questions:

- Why create a blog?
- Where should I host it?
- Which technology should I use?
- Which theme should I choose?

You may notice that these questions gradually move from theory to implementation.

## The big question: why create a blog?

Why would anyone spend their precious time maintaining a blog?

Searching for "Why should I have a blog?" usually leads to answers related to business:

- Increase your visibility
- Build credibility
- Demonstrate expertise
- Improve your online presence

Those can all be valid reasons.

But I also remember watching someone on YouTube criticizing blogs.

His argument was simple: everybody starts one, but very few people continue writing regularly.

As a result, many blogs end up looking like abandoned showcases of their authors.

And there is some truth in that.

A blog only becomes interesting if you keep feeding it with new ideas, experiments, and discoveries.

But during the same video, he also showed several interesting blogs containing unexpected and personal content.

That was a useful reminder:

**blogging is still worthwhile, but it requires effort.**

So why am I doing it?

### First: it is an exercise

Because I work in IT, I wanted to understand how blogging platforms work.

What technologies are available?

How do static websites work?

How are they built and deployed?

How much can I customize?

Building the blog itself became part of the learning process.

### Second: I wanted one place for several purposes

I wanted somewhere to publish articles about ideas, experiments, and discoveries.

But I also wanted somewhere to centralize my technical documentation.

A long time ago, when I was starting in IT and had absolutely no idea what I was doing, I simply stored my notes in OneNote.

Yes, I know.

I was young.

For technical documentation, that eventually became frustrating:

- No proper version control
- Poor code highlighting
- Proprietary storage
- Awkward sharing
- Copy/paste sometimes turning code into images
- Search that did not always give useful results
- Increasing difficulty keeping years of notes organized

Over time, my personal documentation kept growing, and maintaining it became tedious.

I wanted something simpler.

My requirements were roughly:

- Markdown
- Editable from a normal text editor or terminal
- Version controlled
- Easy to search
- Easy to publish when I want to share something
- Portable between hosting solutions
- Open source whenever possible

At first, I considered moving everything into Markdown and publishing it with something like mdBook.

That would have worked well for documentation.

But I also wanted to write less formal posts about ideas, experiments, and personal reflections.

That pushed me toward a blog.

So, let's build one.

It is also a way to open the door to the 🌏.

## Where should I host my blog?

My first thought was naturally:

**self-host it.**

A VPS would give me complete control.

But that also means maintaining another server, web service, TLS configuration, backups, updates, monitoring, and so on.

That seemed like unnecessary work for a static blog.

There are easier solutions such as WordPress, HubSpot, and other CMS platforms.

They handle most of the infrastructure for you.

But I was not completely comfortable with the idea of building everything around a platform that could become difficult to leave later.

Yes, content can usually be exported.

But exporting from one CMS and importing into another often means:

- Converting formats
- Fixing layouts
- Recovering metadata
- Rebuilding themes
- Understanding why something does not render correctly anymore

I wanted to keep **vendor lock-in** as low as possible.

My content should remain simple files that I own.

### GitHub Pages

GitHub provides free static-site hosting through **GitHub Pages**.

One major advantage is that the website can live directly next to its source code.

That means:

```text
Markdown
   │
   ▼
Git repository
   │
   ▼
GitHub Actions
   │
   ▼
Static website
```

The entire site remains portable.

If I decide to move away from GitHub later, I still have:

- My Markdown files
- My configuration
- My theme
- My assets
- My build process

I can rebuild the same website somewhere else.

Another useful aspect is GitHub Actions, which lets us automate the build and deployment process.

GitHub Pages supports account or organization sites such as:

```text
https://username.github.io
```

and project sites such as:

```text
https://username.github.io/repository
```

The latter can also be useful for project documentation.

## Which technology should I choose?

Static site generators are a natural companion to GitHub Pages.

The idea is straightforward:

```text
Markdown + templates + configuration
              │
              ▼
      Static site generator
              │
              ▼
          HTML / CSS / JS
```

The generated files can then be served by almost any web server.

For this first version of the blog, I chose:

- GitHub Pages
- Hugo
- Markdown

Markdown was particularly attractive because it keeps the content simple and portable.

One thing I appreciate about Markdown is how consistent documentation becomes.

Instead of thinking constantly about presentation, I can focus on content.

### Why Hugo?

Working with Hugo is convenient.

While writing an article, I can simply run:

```bash
hugo server -D
```

and preview the entire website locally, including draft posts.

I also considered other static-site generators.

Jekyll is historically very well integrated with GitHub Pages and uses Ruby.

Zola was another interesting option, but at the time I found fewer themes that matched what I wanted.

Hugo was popular, fast, and had plenty of documentation, tutorials, and themes available.

That was enough for me.

Keep it simple.

## Which theme should I use?

Choosing a theme may sound trivial, but good documentation makes a huge difference.

Some themes look great but provide almost no documentation beyond pointing you back to the Hugo documentation.

I wanted a few basic features:

- Table of contents
- Multilingual support
- Local search
- Syntax highlighting
- Comments
- Font-size controls
- Responsive layout
- Light and dark modes

Nothing extraordinary.

Just the features I expected from a technical blog.

For the first version, I chose
[Hugo Theme Bootstrap](https://github.com/razonyang/hugo-theme-bootstrap).

It looked fairly classical, but it was efficient and included many useful widgets.

It was also relatively easy to configure and extend.

Here is a quick overview of what the theme provided:

![Center](./posts/howto-create-this-blog/HBS-list-feat.PNG#center)

## Let's build it

Everything below describes the setup I used for this **first version** of the blog.

The commands and configuration are specific to the version of Hugo Theme Bootstrap I was using at the time, so newer versions or different themes may require changes.

## Prerequisites

The original setup required:

- Node.js
- npm
- Go
- Dart Sass
- Hugo Extended

The installation was done from Ubuntu running under WSL.

```bash
# Install Node.js, npm and Git
sudo apt install nodejs npm git

# Install Go
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Install Dart Sass
DART_SASS_VERSION="1.66.1"
curl -LJO https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz
tar -xf dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz
sudo cp -r dart-sass/* /usr/local/bin
rm -rf dart-sass*

# Install Hugo Extended (.deb)
HUGO_VERSION="0.117.0"
curl -LJO https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb
sudo apt install -y ./hugo_extended_${HUGO_VERSION}_linux-amd64.deb

# Install Hugo Extended on RHEL 9
HUGO_VERSION="0.135.0"
curl -LJO https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz
tar -xzf hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz
sudo mv hugo /usr/bin/hugo

hugo version
```

At the time, my Ubuntu installation reported:

```text
hugo v0.117.0-b2f0696cad918fb61420a6aff173eb36662b406e+extended linux/amd64 BuildDate=2023-08-07T12:49:48Z VendorInfo=gohugoio
```

You could also install some of the tools using Snap:

```bash
sudo snap install dart-sass
sudo snap install hugo

which hugo
/snap/bin/hugo

hugo version
```

## Creating the project

Create an empty GitHub repository and clone it locally.

For this version of the site, the theme was installed as a Git submodule:

```bash
cd myblog

git submodule add https://github.com/razonyang/hugo-theme-bootstrap themes/hugo-theme-bootstrap

git clone https://github.com/razonyang/hugo-theme-bootstrap-skeleton /tmp/hbs-skeleton

mkdir config

cp -a /tmp/hbs-skeleton/config/* ./config
cp -r /tmp/hbs-skeleton/content/* ./content
cp -r /tmp/hbs-skeleton/archetypes/* ./archetypes
cp -r /tmp/hbs-skeleton/static/* ./static
cp -r /tmp/hbs-skeleton/assets/* ./assets

sed -i "s/theme:.*/theme: hugo-theme-bootstrap/g" config/_default/config.yaml

hugo mod npm pack
npm install

hugo server
```

At that point, the first version of the blog was already running locally.

## A few settings

Two important configuration files were:

```text
author.yaml
params.yaml
```

`author.yaml` contained information about the author and social links.

`params.yaml` controlled global appearance and theme options.

## Add another language

Languages were declared inside:

```text
./config/_default/languages.yaml
```

Additional configuration and menu files could then be created for each language.

For example:

```text
config git:main ❯ tree -L 2
.
├── _default
│   ├── author.yaml
│   ├── config.fr.yaml
│   ├── config.pl.yaml
│   ├── config.yaml
│   ├── languages.yaml
│   ├── menu.en.yaml
│   ├── menu.fr.yaml
│   ├── menu.pl.yaml
│   ├── params.yaml
│   ├── server.yaml
│   └── social.yaml
└── production
    ├── config.yaml
    └── params.yaml
```

Translated content could then use files such as:

```text
index.md
index.fr.md
index.pl.md
```

## A word about Giscus

The theme supported **Giscus**, a comment system based on GitHub Discussions.

Comments posted on the blog are stored as discussions in the GitHub repository.

To configure it, I needed to:

- Make the repository public
- Enable GitHub Discussions
- Install the [Giscus GitHub App](https://github.com/apps/giscus)
- Configure the application for the blog repository
- Provide the repository information in the Hugo configuration

For example:

```yaml
# See https://giscus.app
giscus:
  repo: "MozeBaltyk/mozebaltyk.github.io"
  repoId: "R_kgDOKJSCfA"
  category: "General"
  categoryId: "DIC_kwDOKJSCfM4CYvA_"
```

Visitors need a GitHub account to post comments through Giscus.

## Change the table of contents

At the time, the table of contents displayed headings from specific levels, and I did not find a theme parameter in `./config/_default/params.yaml` to change all of its behavior directly.

This was one of those small details that required looking beyond the theme's main configuration.

## Change syntax highlighting

Hugo can generate Chroma stylesheets.

For example:

```sh
hugo gen chromastyles --style=dracula > assets/main/scss/_highlight.scss
```

That allowed me to customize code highlighting.

## Add extra icons

Additional Font Awesome icons could be imported through:

```text
./assets/icons/custom.js
```

For example:

```js
import {
    faBlog,
    faBook,
    faFile,
    faNewspaper,
    faAnchor,
    faInfinity,
    faCode,
    faBug,
    faLightbulb,
    faTerminal,
} from '@fortawesome/free-solid-svg-icons';

const icons = [
    faBook,
    faBlog,
    faFile,
    faNewspaper,
    faAnchor,
    faInfinity,
    faCode,
    faBug,
    faLightbulb,
    faTerminal,
];

export default icons;
```

Those icons could then be reused by the theme.

## Writing articles

Of course, you can write articles with Vim, Neovim, or whichever editor you prefer.

One simple approach is to use one directory per article.

For multilingual content:

```bash
hugo new news/new-post/index.md
hugo new news/new-post/index.fr.md
hugo new news/new-post/index.pl.md
```

Another approach is to organize several articles under a section:

```bash
vi docs/Devops/Containers/_index.md

hugo new docs/Devops/Containers/docker.md
hugo new docs/Devops/Containers/podman.md
```

In Hugo, `_index.md` can define a section.

New posts are usually created as drafts.

To preview drafts:

```bash
hugo server -D
```

Before publishing, either remove the `draft` parameter or set:

```yaml
draft: false
```

## Images

There were several ways to manage images.

One approach was to store an image under the static directory and reference it from the front matter.

For example:

```yaml
---
title: 📡 The Bad, the Good and the Ugly Git
# [...]
authors:
  - mozebaltyk
images:
  - ./bad-good-ugly-git/carousel.webp
---
```

Another approach was to keep images directly next to the article as page resources.

The theme could automatically recognize filenames such as:

```text
feature.*
cover.*
thumbnail.*
```

These resources could then be resized into several versions for different screen sizes.

Other article images could simply be stored in the article directory and referenced from Markdown:

```markdown
![Center](/HBS-list-feat.PNG#center)
```

## Organization

Hugo taxonomies help classify relationships between pieces of content.

For this blog, the main concepts were:

- Series
- Categories
- Tags
- Featured posts

Understanding these early makes the site much easier to organize as the number of articles grows.

## Publishing the blog

For deployment, I used GitHub Actions to build the Hugo website and publish it through GitHub Pages.

My workflow also evolved over time.

Initially, every push triggered a deployment.

That was convenient, but it gave me almost no time to reread an article after committing it.

I later experimented with manual deployment using:

```text
workflow_dispatch
```

Eventually, I moved toward a branch-based workflow where publication happens only after changes reach the branch used for production.

Branch protection can also help prevent accidental publication.

For example:

**Lock branch**

prevents direct modifications to a protected branch.

Another useful setting is:

**Require a pull request before merging**

which encourages reviewing changes before publication.

I will not include the entire workflow here.

The current workflow files can be found in the blog repository:

[GitHub workflows](https://github.com/MozeBaltyk/mozebaltyk.github.io/tree/main/.github/workflows)

At a high level, the workflow contained two jobs:

```yaml
jobs:

  # Build job
  build:
    runs-on: ubuntu-latest

    env:
      HUGO_VERSION: 0.117.0

    steps:
      - name: Install Hugo CLI

      - name: Checkout 🛎️

      - name: Setup Node

      - name: Cache dependencies

      - name: Install dependencies

      - name: Setup Hugo

      - name: Setup Pages

      - name: Install Node.js dependencies

      - name: Build with Hugo

      - name: Upload artifact

  # Deployment job
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}

    runs-on: ubuntu-latest
    needs: build

    steps:
      - name: Deploy to GitHub Pages 🚀
        id: deployment
        uses: actions/deploy-pages@v2
```

Conceptually:

```text
Markdown / Hugo
      │
      ▼
 Git repository
      │
      ▼
GitHub Actions
      │
      ├── Build
      │
      ▼
 Static files
      │
      ▼
 GitHub Pages
```

## Updating the blog

Some generated files and dependencies should not be stored in Git.

My `.gitignore` included:

```text
.hugo_build.lock
hugo_stats.json
node_modules/
resources/
```

The original theme was installed as a Git submodule, so updating it looked like this:

```bash
cd themes/hugo-theme-bootstrap

git fetch
git checkout [version]

cd ../../

hugo mod npm pack
npm update

git add \
  themes/hugo-theme-bootstrap \
  package.hugo.json \
  package.json \
  package-lock.json

git commit -m 'Bump theme to [version]'
```

## Looking back

This setup was the first version of the blog.

It was not perfect, and the theme was eventually replaced, but the important decisions survived:

- Write content in Markdown
- Keep everything in Git
- Generate a static website
- Automate deployment
- Avoid unnecessary vendor lock-in
- Keep the content portable

The implementation has changed since then.

The philosophy has not changed very much.

That is probably the most interesting part of looking back at this first version.

## 💡 Bonus point

For anyone who made it all the way to the end:

do not forget to add a few ridiculous
[Markdown emojis](https://github.com/markdown-templates/markdown-emojis)
to your posts. 😄

## Sources

- [Hugo Theme Bootstrap documentation](https://hbs.razonyang.com/v1/en/docs/getting-started/prerequisites/)
- [Hugo Theme Bootstrap skeleton](https://github.com/razonyang/hugo-theme-bootstrap-skeleton/blob/main/README.md)
- [Hugo Theme Bootstrap — GitHub Pages deployment](https://hbs.razonyang.com/v1/en/docs/deployment/github-pages/)
- [GitHub Pages documentation](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow)
