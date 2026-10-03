<h1 style="text-align: center;"><code> Bałtyk Blog </code></h1>

[![Deployed](https://github.com/MozeBaltyk/mozebaltyk.github.io/actions/workflows/gh-pages.yaml/badge.svg)](https://github.com/MozeBaltyk/mozebaltyk.github.io/actions/workflows/gh-pages.yaml)
[![Link](https://img.shields.io/badge/This_Blog-blue.svg)](https://mozebaltyk.github.io/)


## Organisation of this blog

Content is organised along **three taxonomies**, each with a different purpose:

* **Series** — a *guided journey*: an ordered reading path through related posts.
* **Categories** — the *type* of content (what kind of piece it is).
* **Tags** — a deliberately *small, fixed vocabulary* of precise *topics*.

### Series (thematic journeys)

* Workstation
* Homelab Journey
* Building This Blog
* Building a Tool
* Infrastructure
* Open Source

### Categories (the type of content)

`Reflection` · `Memo` · `Tutorials` · `Hacking`

* **Reflection** — an opinion/experience essay ("Did I Reinvent the Wheel?", "My Workstation").
* **Tutorials** — a step-by-step how-to ("How I Created This Blog", "The Beauty of WSL").
* **Memo** — a quick reference / cheatsheet (most of `/docs`).
* **Hacking** — security & pentesting notes (the only *domain* category, kept for the scanning content).

### Tags (a fixed list — we keep it small on purpose)

We deliberately **limit the number of tags**:

* one term per concept (no `Certificates` alongside `Certificate`, no `OpenSources` vs `Open Source`);
* a tag must be **reused** to stay — one-off tags get absorbed into the closest term or dropped;
* spelling/case is **fixed** (e.g. `Windows / WSL`, `CI/CD`, `Open Source`), because related-content matching is case-sensitive.

`Linux` · `Kubernetes` · `Containers` · `Networking` · `Storage` · `Virtualization` · `Security` · `Git` · `IaC` · `Ansible` · `Scripting` · `Shell` · `Windows / WSL` · `Homelab` · `Hugo` · `Databases` · `CI/CD` · `Gitops`

### What goes where

| Taxonomy | Purpose | Count | Per piece |
|---|---|---|---|
| Series | ordered reading path | few, curated | 0 or 1 |
| Categories | content type | 4 | 1 |
| Tags | precise topics | 18 (fixed) | 1–3 |

### Conventions for new posts & docs

* Pick **one category** by the *type* of content (`Reflection`, `Memo`, `Tutorials` or `Hacking`) and **1–3 tags from the fixed list** — don't invent new tags without updating this document.
* Assign a **series** only when it's part of a real narrative; otherwise omit it (or use `Docs`/`Posts` for the structural sections).
* Write in **English**; keep commands in fenced code blocks.
* Docs live under `content/docs/<Section>/…` and are ordered with `nav_weight` (lower = higher in the nav); posts live under `content/posts/<slug>/`.
* Use theme **shortcodes** for notes (`{{< bs/alert info >}}`, `{{< bs/alert warning >}}`) rather than plain `>` blockquotes or GitHub `> [!NOTE]` callouts (the latter don't render here).

## Authoring: shortcodes, images & carousel

### code-snippet — embed a snippet from a file

Keeps long code blocks out of the Markdown; the snippet lives in its own file.

```text
{{< code-snippet "example.conf" "ini" >}}
```

Resolution (hybrid), in order:

1. the article's own bundle folder `code/` or `codes/` (posts are leaf bundles);
2. the shared `assets/codes/` library (for leaf-page **docs**).

The language is optional — it falls back to the file extension, then `txt`.

```text
{{< code-snippet "oracle/reclaim_space.sql" "sql" >}}   → assets/codes/oracle/reclaim_space.sql
{{< code-snippet "example.txt" >}}                      → content/posts/…/codes/example.txt
```

> When *documenting* the shortcode itself, escape it with `{{</* code-snippet … */>}}` so Hugo doesn't execute it.

### table-snippet — render a table from YAML / JSON / TOML

```text
{{< table-snippet "file" "columns" "sort" "filter" >}}
```

Resolution: the bundle `table/`/`tables/` folders first, then `data/` (nested path — `data/systems/unix-like/runlevels.yaml` → `"systems/unix-like/runlevels"`).

* `columns` — comma-separated keys (omit to use every key); the headers are generated automatically.
* `sort` / `filter` — optional key to sort by, and a boolean key to keep only rows where it is `true`.
* Cell values are markdownified; URLs become clickable links.

### Images

* Global images: `static/images/` (referenced as `images/foo.png` — avatar, logo, default thumbnail).
* Per-article images: the page's `images/` bundle folder, or `static/posts/<slug>/`.

### Carousel

```yaml
carousel: true          # enable the image carousel on this post
featured: true          # mark as featured (surfaced on the homepage)
images:
  - ./carousel/my-post.webp
```

* Carousel images live in `static/carousel/`.
* Featured posts drive the homepage carousel (tuned via `featured_posts` in `params.yaml`).

### Hybrid codes — bundle vs shared

`code-snippet` tries the article's own `codes/` first (post-style), then the shared `assets/codes/`:

* a snippet that belongs to a **single** article → its `codes/` bundle folder;
* a snippet **reused** across articles → `assets/codes/` (give the folder path as the argument).

## Important links

[theme doc](https://hbstack.dev/)
[theme source](https://github.com/hbstack/theme-cards)
[Examples](https://hbstack.dev/examples/)
[Add/Remove a Module ](https://hbstack.dev/modules/overview/)

## Run it locally

### Manually

```bash
npm ci 
npm run dev
npm run prod
```

### or with docker 

The two way to build it with docker:

* DEV mode
```bash
# run it with the hugo image - closer to the manual way
podman build \
  -t user/my-site:1 \
  --build-arg HUGO_BASEURL=http://localhost:8080 \
  -f Dockerfile.dev

podman run -it -p 1313:1313 --rm localhost/user/my-site:1 hugo server -D
```

* the more clean, slim and ready for deployment way:
```bash
# Build it
podman build \
  -t user/my-site:test \
  --build-arg HUGO_BASEURL=http://localhost:8080 \
  .
# Run it
podman run -p 8080:80 user/my-site:test
# Check it
podman images
podman ps -a
# Clean it
podman rmi $(podman images --filter=reference='*test*' -q)
podman image prune -a -f
```

## Some good examples with this theme

| Website | source code |
| :-: | :-: |
| https://rootandbeer.com/ | https://github.com/rootandbeer/rootandbeer.github.io |