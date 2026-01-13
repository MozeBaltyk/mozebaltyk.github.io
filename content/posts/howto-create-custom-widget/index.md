---
title: "How to Create Custom Widget"
date: 2026-01-13T15:09:09+01:00
draft: false
description: "How to create a custom sidebar widget in a Hugo static website."
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
images:
  - ./howto-create-custom-widget/carousel.jpg
authors:
  - mozebaltyk
sidebar: false
---

## The context

For my blog, I use [HBStack](https://hbstack.dev/sites/) with the
[hbcards/theme](https://hbstack.dev/themes/cards/), which relies heavily on Hugo modules.  
This setup makes configuration easier and provides a clean, modular
architecture.

One powerful feature of this theme is the availability of **hooks** at
different levels of the rendering process. These hooks allow us to
customize the blog without modifying the theme itself.

In this article, we will develop a **custom sidebar widget** that
displays a random citation (quote, joke, or technical wisdom) on each
page load.

##  Data in Hugo

At the project root, the `./data` directory is used by **Hugo at build
time** to populate the `.Site.Data` object.  
Hugo supports several data formats including JSON, TOML, YAML, and XML.

For this exercise, I created three data files, each representing a
category of citations:  

For our exercice, I have created 3 files gathering 3 categories of citations:

```txt
data
└── sidebar
    ├── jokes.yaml
    ├── quotes.yaml
    └── wisdom.yaml
```

Because Hugo generates a **static website**, this data cannot be queried
dynamically at runtime. Instead, the data must be rendered into the HTML
during the build process. So we use for this, a hook given by HB theme `layouts\partials\hugopress\modules\hb-custom\hooks\hb-blog-sidebar.html`.

To keep the page clean, we embed the data as hidden HTML elements using
`data-*` attributes. JavaScript can then read these attributes once the
page is loaded in the browser. A loop which use `site.Data.sidebar.<filename>` 
to include the data in the website.   

```html
<div class="hb-module text-center">
  <aside class="hb-sidebar">

    <section class="hb-sidebar-box random-citation js-random-citation">
      <h5 id="citation-title"></h5>

      <blockquote id="citation-content"></blockquote>

      <!-- Hidden category data -->
      <div class="citation-data" hidden>

        <!-- Quotes -->
        <div class="citation-category" data-category="quote" data-title="💬 Quote">
          {{ range site.Data.sidebar.quotes }}
            <div
              data-text="{{ .text }}"
              data-author="{{ .author }}">
            </div>
          {{ end }}
        </div>

        <!-- Jokes -->
        <div class="citation-category" data-category="joke" data-title="😂 IT Joke">
          {{ range site.Data.sidebar.jokes }}
            <div data-text="{{ . }}"></div>
          {{ end }}
        </div>

        <!-- Wisdom -->
        <div class="citation-category" data-category="wisdom" data-title="🧠 Tech Wisdom">
          {{ range site.Data.sidebar.wisdom }}
            <div data-text="{{ . }}"></div>
          {{ end }}
        </div>

      </div>
    </section>

  </aside>
</div>
```

For troubleshooting, you can inspect the page source and search for the
`random-citation` class to verify that the data is correctly embedded.

## Typescript or Javascript

JavaScript is the language executed by the browser, while TypeScript is a
**superset of JavaScript** that adds static typing and better tooling.

In this project, we write our code in TypeScript (`.ts`) because:
- It catches errors at build time
- It provides better autocompletion and documentation
- It compiles down to plain JavaScript for the browser

Hugo Pipes automatically compiles the TypeScript file into JavaScript,
so the browser never sees the `.ts` file directly.

The theme does not automatically include custom JavaScript files.
Instead, we explicitly register our TypeScript file using a Hugo hook so
it can be compiled and injected into the page.

Let's take the Example below written in `.\assets\hb\modules\custom\js\index.ts`:

```ts
console.log("✅ Random citation script loaded");

// Random citation (no dependencies)
document.addEventListener("DOMContentLoaded", () => {
  const container = document.querySelector<HTMLElement>(".js-random-citation");
  if (!container) return;

  const categories = container.querySelectorAll<HTMLElement>(
    ".citation-category"
  );
  if (!categories.length) return;

  // 1️⃣ Pick a random category
  const category =
    categories[Math.floor(Math.random() * categories.length)];

  const title = container.querySelector<HTMLElement>("#citation-title");
  const blockquote = container.querySelector<HTMLElement>("#citation-content");

  if (!title || !blockquote) return;

  title.textContent = category.dataset.title ?? "";

  // 2️⃣ Pick a random item inside the category
  const items = category.querySelectorAll<HTMLElement>("div");
  if (!items.length) return;

  const chosen = items[Math.floor(Math.random() * items.length)];

  const text = chosen.dataset.text ?? "";
  const author = chosen.dataset.author;

  blockquote.innerHTML = `
    “${text}”
    ${author ? `<footer>— ${author}</footer>` : ""}
  `;
});
// End of random citation
```

## How to use it 

Hugo generates a static website, meaning all processed files are written
to the `./public` directory, which is then served by a web server.

After compilation, our TypeScript code is bundled into a JavaScript file
(e.g. `hb.js`) inside the `public` directory.

To make the script available on the website, we load it using another
HBStack hook located at:

`layouts/partials/hugopress/modules/hb-custom/hooks/hb-head-end.html`

```html
{{/* Load custom sidebar JS */}}
{{ $js := resources.Get "hb/modules/custom/js/index.ts" | js.Build | minify | fingerprint }}
<script src="{{ $js.RelPermalink }}" defer></script>
```

## The Result

The result is a sidebar widget that displays a different citation each
time a page is loaded, creating the impression of randomness while
remaining fully static.

![Random citation widget](./howto-create-custom-widget/result_widget.png#center)
