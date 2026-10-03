<h1 style="text-align: center;"><code> Bałtyk Blog </code></h1>

[![Deployed](https://github.com/MozeBaltyk/mozebaltyk.github.io/actions/workflows/gh-pages.yaml/badge.svg)](https://github.com/MozeBaltyk/mozebaltyk.github.io/actions/workflows/gh-pages.yaml)
[![Link](https://img.shields.io/badge/This_Blog-blue.svg)](https://mozebaltyk.github.io/)


## Organisation of this blog

Content is organised along **three taxonomies**, each with a different purpose:

* **Series** — a *guided journey*: an ordered reading path through related posts.
* **Categories** — a small set of broad *themes*.
* **Tags** — a deliberately *small, fixed vocabulary* of precise *topics*.

### Series (thematic journeys)

* Workstation
* Homelab Journey
* Building This Blog
* Building a Tool
* Infrastructure
* Open Source
* Docs *(structural)*
* Projects *(structural)*

### Categories (one per piece)

`Devops` · `SysAdmin` · `DBA` · `Tutorials` · `Hacking` · `Network` · `Homelab`

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
| Categories | broad theme | 7 | 1 |
| Tags | precise topics | 18 (fixed) | 1–3 |

### Conventions for new posts & docs

* Pick **one category** (the closest of the seven) and **1–3 tags from the fixed list** — don't invent new tags without updating this document.
* Assign a **series** only when it's part of a real narrative; otherwise omit it (or use `Docs`/`Posts` for the structural sections).
* Write in **English**; keep commands in fenced code blocks.
* Docs live under `content/docs/<Section>/…` and are ordered with `nav_weight` (lower = higher in the nav); posts live under `content/posts/<slug>/`.
* Use theme **shortcodes** for notes (`{{< bs/alert info >}}`, `{{< bs/alert warning >}}`) rather than plain `>` blockquotes or GitHub `> [!NOTE]` callouts (the latter don't render here).

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