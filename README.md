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
* Assign a **series** only when it's part of a real narrative; otherwise omit it entirely.
* Write in **English**; keep commands in fenced code blocks.
* Docs live under `content/docs/<Section>/…` and are ordered with `nav_weight` (lower = higher in the nav); posts live under `content/posts/<slug>/`.
* Use theme **shortcodes** for notes (`{{< bs/alert info >}}`, `{{< bs/alert warning >}}`) rather than plain `>` blockquotes or GitHub `> [!NOTE]` callouts (the latter don't render here).

## Bilingual content & the Courses page

The site is multilingual: **English** (default, at the root) plus **Polish** (under
`/pl/`). The header **language switch** appears automatically once more than one
language is listed in `config/_default/languages.yaml`.

- Only the **Courses** section is translated so far. To translate more content, add a
  `*.pl.md` file next to the `*.en.md` (or `index.md`). Untranslated pages simply stay
  on the default (English) site.

### Courses

`content/courses/` is a **bilingual section** of the site — a four-level practical
IT path for young learners, separate from the blog (`posts`) and documentation
(`docs`) sections:

- The **homepage** (`_index.en.md` / `_index.pl.md`) is `type: courses`, rendered by
  `layouts/courses/list.html` — a landing page with a *Start Course* button, *latest
  lessons*, a *series progress* checklist, and a *For Parents* call-to-action.
- Course content lives under `content/courses/<level>/<area>/`. Every level repeats
  Foundations, Infrastructure, Linux, Programming, and Challenges.
- `data/courses/curriculum.yaml` defines the four-level roadmap, localized titles,
  link availability, and lesson status (`done` | `current` | `todo`).
- `listed` controls links, while status records whether a lesson has been taught.
- The language-aware **citation sidebar** (stoic quotes) is hooked into the docs nav
  via `hb-docs-nav-beforeend`, gated to course pages only.

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

* Global/theme images (avatar, logo, default thumbnail, favicon): `assets/images/` — referenced as `images/foo.png` in `params.yaml`.
* Per-article body images: `static/posts/<slug>/`.
* Featured/carousel images: the post's own `carousel/` bundle folder (see Carousel below).

### Carousel

The **homepage** carousel shows the *featured* posts, using each post's first `images:` entry as its slide image.

```yaml
featured: true          # make the post appear in the homepage carousel
images:
  - carousel/my-post.webp
```

* Carousel images live in the post's own bundle folder `content/posts/<slug>/carousel/`, referenced with a **relative** path (no leading `./` or `/`) so they are picked up as page resources (processed + lazy-loaded).
* `featured: true` (with an image) is what surfaces the post in the homepage carousel; the number shown is tuned via `featured_posts` in `params.yaml`.
* The legacy `carousel: true` frontmatter flag is **not read** by the theme — it can be dropped.

For a carousel **inside an article**, use the custom `image-carousel` shortcode
with at least two images. Each argument is `IMAGE|ALT` or
`IMAGE|ALT|CAPTION`:

```text
{{< image-carousel
  "/images/computers/cpu.webp|A processor on a motherboard|The processor"
  "/images/computers/ram.webp|Two RAM modules|Short-term memory"
>}}
```

Paths may point to files in `static/` (as above) or to page-bundle resources.

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
