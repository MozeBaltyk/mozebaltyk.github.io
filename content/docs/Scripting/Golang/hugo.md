---
date: 2026-01-01T21:00:00+08:00
title: ⚡ Hugo
nav_weight: 50
categories:
  - Memo
tags:
  - Scripting

---

## What is Hugo

[Hugo](https://gohugo.io/) is a fast static site generator, written in Go.

It turns Markdown + templates + config into a static website.

## Install

Use the **extended** build if you process SCSS (this theme does):

```bash
# binary
curl -L https://github.com/gohugoio/hugo/releases/download/v0.154.3/hugo_extended_0.154.3_linux-amd64.tar.gz | tar -xz
sudo mv hugo /usr/local/bin/hugo

# or snap
sudo snap install hugo
```

You also need **Dart Sass** and **Node/npm** for SCSS + PostCSS.

## New site

```bash
hugo new site myblog
cd myblog
```

## Content

```bash
hugo new posts/first-post.md   # draft: true by default
```

## Serve / Build

```bash
hugo server -D                 # dev server, include drafts
hugo                           # build into public/
hugo --gc                      # build + garbage-collect cache
hugo --minify -e production    # production build
```

## Layout

```text
content/     source markdown
layouts/     templates (override the theme)
static/      files copied as-is (images, favicons)
data/        site data (.yaml/.json/.toml)
config/      configuration (hugo.yaml, params, menus)
public/      generated site (gitignored)
```

## Front matter

```yaml
---
title: "First Post"
date: 2026-01-01T00:00:00+02:00
draft: true
---

Content.
```

## Templates & partials

- `layouts/_default/single.html`, `list.html`, `baseof.html`
- Override anything from the theme by mirroring the path in `layouts/`.
- Partials: `{{ partial "name" . }}`

## Useful functions

```go
{{ .Title }}          {{ .Content }}      {{ .Params.custom }}
{{ range ... }}       {{ if ... }}        {{ with ... }}
{{ resources.Get "x" | minify | fingerprint }}
```

## Modules

```bash
hugo mod get -u ./...   # update modules
hugo mod tidy
hugo mod graph          # list the module graph
```

## Key notes

- `_index.md` = section page; `index.md` = leaf bundle page.
- `draft: true` pages only appear with `hugo server -D`.
- The `./`-relative image paths resolve against `static/`, not the content bundle.