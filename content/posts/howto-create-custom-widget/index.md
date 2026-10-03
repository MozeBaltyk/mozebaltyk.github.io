---
title: "🎺 How to Create a Widget for Hugo."
description: "How to create a custom sidebar widget in a Hugo static website."
date: 2026-01-13T15:09:09+01:00
draft: false
noindex: false
featured: true
pinned: false
comment: true
toc: true
reward: true
carousel: true
series:
  - Building This Blog
categories:
  - Tutorials
tags:
  - Hugo
  - Scripting
images:
  - carousel/howto-create-custom-widget.jpg
authors:
  - mozebaltyk
sidebar: false
---

## The context

For my blog, I use [HBStack](https://hbstack.dev/sites/) with the
[hbcards/theme](https://hbstack.dev/themes/cards/), which relies heavily on Hugo modules.

This setup makes configuration easier and provides a clean, modular architecture.

One powerful feature of this theme is the availability of **hooks** at
different stages of the rendering process. These hooks allow us to
customize the blog without modifying the theme itself.

In this article, we will develop a **custom sidebar widget** that
displays a random citation — a quote, joke, or piece of technical wisdom — each time a page is loaded.

## Data in Hugo

At the project root, the `./data` directory is used by **Hugo at build
time** to populate the `.Site.Data` object.

Hugo supports several data formats, including JSON, TOML, YAML, and XML.

For this exercise, I created three data files, each representing a
different category of citations:

```txt
data
└── sidebar
    ├── jokes.yaml
    ├── quotes.yaml
    └── wisdom.yaml
```

Because Hugo generates a **static website**, this data cannot be queried
dynamically at runtime.

Instead, the data must be rendered into the HTML during the build process.

For this, we use a hook provided by the HB theme:

`layouts/partials/hugopress/modules/hb-custom/hooks/hb-blog-sidebar.html`

To keep the page clean, we embed the data as hidden HTML elements using
`data-*` attributes.

JavaScript can then read these attributes once the page has been loaded in the browser.

A loop based on `site.Data.sidebar.<filename>` is used to include the
data in the generated website.

{{< code-snippet hb-blog-sidebar.txt html >}}

## TypeScript or JavaScript?

JavaScript is the language executed by the browser, while TypeScript is a
**superset of JavaScript** that adds static typing and improved tooling.

In this project, we write our code in TypeScript (`.ts`) because:

- It catches many errors at build time
- It provides better autocompletion
- It improves code readability and maintainability
- It compiles down to plain JavaScript for the browser

Hugo Pipes can compile the TypeScript file into JavaScript, so the browser
never sees the `.ts` file directly.

The theme does not automatically include custom JavaScript files.

Instead, we explicitly register our TypeScript file using a Hugo hook so
that it can be compiled and injected into the page.

Let's take the following example, located at:

`./assets/hb/modules/custom/js/index.ts`

{{< code-snippet index.ts >}}

## How to use it

Hugo generates a static website, meaning all processed files are written
to the `./public` directory, which is then served by a web server.

After compilation, our TypeScript code is bundled into a JavaScript file
inside the `public` directory.

To make the script available on the website, we load it using another
HBStack hook located at:

`layouts/partials/hugopress/modules/hb-custom/hooks/hb-head-end.html`

```html
{{/* Load custom sidebar JS */}}
{{ $js := resources.Get "hb/modules/custom/js/index.ts" | js.Build | minify | fingerprint }}
<script src="{{ $js.RelPermalink }}" defer></script>
```

This ensures that the generated JavaScript is included in the page and
executed by the browser.

## The result

The result is a sidebar widget that displays a different citation each
time a page is loaded.

The site remains fully static, while the browser randomly selects which
citation to display at runtime.

![Random citation widget](./posts/howto-create-custom-widget/result_widget.png#center)

## Troubleshooting

1. Inspect the page source and search for the
   `random-citation` class to verify that the data is correctly embedded.

2. Add a log statement at the top of `index.ts`:

```ts
console.log("Random citation script loaded");
```

Open DevTools → Console and reload the page.

If the message does not appear, the script is not being loaded.

Verify the `hb-head-end.html` hook and the `resources.Get` path.

3. Test DOM access manually.

In DevTools → Console, run:

```js
document.querySelector(".citation-category div")?.dataset
```

This allows you to verify that the `data-*` attributes are accessible from
JavaScript.

## Data flow diagram

The following diagram illustrates how data flows from Hugo to the browser
and finally into the rendered widget.

At no point does JavaScript access Hugo data directly.

All data access happens through the DOM via `data-*` attributes that were
generated at build time.

```text
 BUILD TIME (Hugo)
 ─────────────────────────────────────────────────

   data/sidebar/quotes.yaml
   data/sidebar/jokes.yaml
   data/sidebar/wisdom.yaml
              │
              ▼
      ┌─────────────────────┐
      │   .Site.Data        │
      │   (Hugo context)    │
      └─────────┬───────────┘
                │ Go templates
                ▼
      ┌─────────────────────┐
      │ Generated HTML      │
      │ hidden <div> nodes  │
      │ data-* attributes   │
      └─────────┬───────────┘
                │
                │ static HTML
                ▼

 RUNTIME (Browser)
 ─────────────────────────────────────────────────

      ┌─────────────────────┐
      │ Browser DOM         │
      │ (parsed HTML)       │
      └─────────┬───────────┘
                │
                │ JavaScript
                ▼
      ┌─────────────────────┐
      │ index.ts            │
      │ - select category   │
      │ - select citation   │
      └─────────┬───────────┘
                │
                ▼
      ┌─────────────────────┐
      │ Visible Sidebar     │
      │ Random citation     │
      └─────────────────────┘
```