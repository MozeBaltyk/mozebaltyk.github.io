---
title: "✨ How to Write a Hugo Shortcode"
description: "Hugo Shortcodes are reusable snippets to insert dynamic or complex content."
date: 2026-01-16T17:53:54+01:00
draft: false
noindex: false
featured: true
pinned: false
comment: true
toc: true
reward: true
series:
  - Building This Blog
categories:
  - Tutorials
tags:
  - Hugo
  - Scripting
images:
  - carousel/howto-write-hugo-shortcode.avif
authors:
  - mozebaltyk
sidebar: false
---

## Introduction

Shortcodes make it easy to reuse the same logic or markup across your content. They help keep Markdown files readable while allowing you to insert dynamic or configurable elements when needed.

You should consider writing a shortcode when:

- You need to reuse the same component in multiple places
- You want to centralize or share data across different content files
- You need to encapsulate complex or verbose HTML
- You want to ensure consistent presentation across posts
- You need to embed third-party content (videos, tweets, code snippets, etc.)
- You want to separate content from layout and styling concerns
- You need conditional rendering based on parameters or context
- You want to provide simple, author-friendly building blocks instead of raw HTML

## The Basics

To call a shortcode in your post, use its filename (without `.html`).

- Use `{{%/* */%}}` when the shortcode output contains Markdown that must be rendered
- Use `{{</* */>}}` when the shortcode outputs HTML only (preferred for performance)

Examples:

- `{{%/* parameters params.yaml */%}}`      # Markdown-aware
- `{{</* parameters "params.yaml" */>}}`    # HTML-only
- `{{%/* hugo/parameters params.yaml */%}}` # will look for `./layouts/shortcodes/hugo/parameters.html`

{{< bs/alert warning >}}
When documenting Hugo shortcodes, you must escape them using `{{</* /* … */ */>}}`, otherwise Hugo will try to execute them at build time.
{{< /bs/alert >}}

In this [post](https://mozebaltyk.github.io/posts/howto-my-new-blog/#shortcodes), we already saw that we can use shortcodes provided by the theme's modules, but let's write some custom ones.

## Some use cases

### Split code from articles

On this blog, I often include large code blocks. Instead of embedding them directly in Markdown, it’s often cleaner to keep them next to the article—for example, in a `code/` or `codes/` folder—and include them using a dedicated shortcode.

This approach makes the article easier to read and allows *code snippets* to be reused or updated independently of the content. Separating code from content keeps articles readable while letting code evolve independently. You can achieve this with a `code-snippet` shortcode.     

* Shortcode location: `./layouts/shortcodes/code-snippet.html`     

* Content structure example:

```css
content/
└─ posts/
   └─ my-article/
      ├─ index.md
      ├─ codes/
      │  └─ example.conf
```

* The code: 

{{< code-snippet code-snippet.txt go>}} 

* The usage: 

The language is taken from the file extension.
```go
{{</* code-snippet example.txt*/>}} 
```

Or you can declare the language.
```go
{{</* code-snippet example.txt ini*/>}}
```       
      
* The result: {{< code-snippet example.txt ini>}}  
         
{{< bs/alert warning >}}
{{< markdownify >}}
One exception: do not put files with an `.html` extension in the `code` folder; otherwise, Hugo will try to build them.
{{< /markdownify >}}
{{< /bs/alert >}}

### Generate a table from YAML

You can generate a table from a configuration file using a shortcode. This is especially useful when you need to apply custom styling or effects, or when the dataset is large.

Instead of maintaining a long Markdown table, you can store the data in an `a-long-list-of-stuffs.yaml` file, which is easier to read and update over time.

So let's create a *shortcode* that:
- ✔ Generates a valid table
- ✔ Automatically generates headers
- ✔ Makes URLs clickable
- ✔ Renders Markdown / HTML when present
- ✔ Supports YAML / JSON / TOML inputs

* The code in `./layouts/shortcodes/table-snippet.html`:

{{< code-snippet table-snippet.txt go>}} 

* The usage: `{{</* table-snippet list "name,description" */>}}`    

* The result: {{< table-snippet list "name,description" >}}    

Note: Because I generated HTML output, the right syntax is `{{</* */>}}`, not `{{%/* */%}}`, which is *Markdown-aware*.

I then improved the *table-snippet* shortcode so that it:
- ✔ Uses positional parameters only
- ✔ Looks in the page bundle's `table/` or `tables/` directory first, then `data/`
- ✔ Handles nested paths such as *rss/my-super-list*
- ✔ Supports optional sorting arguments
- ✔ Supports optional Boolean filtering arguments

* The usage now: `{{</* table-snippet DATA_FILE COLUMNS SORT FILTER */>}}`   

* Usage example: `{{</* table-snippet rss/list "name,description,url" name active */>}}`

Note about Hugo:
- A page bundle (local to `article/table` or `article/tables`) is scoped to the page
- The global data directory (`data/`) is reusable across the site
- Hugo's configuration loading is *format-agnostic*: `.yaml`, `.yml`, `.json`, and `.toml` files all work

## Some ideas for future shortcodes

Here are a few additional shortcode ideas that would fit well in an IT-focused blog:

* **Diff viewer** — render configuration or code changes in a readable diff format

* **Badges** — display states such as `Active`, `Disabled`, or `Deprecated` with custom styles

* **Timelines** — visualize chronological steps, migrations, or project history

## Summary

Hugo shortcodes act as *"controllers"*. They allow you to:

📄 Keep Markdown clean and readable

🔁 Make data reusable across multiple posts (loading it from the *page* or *data/*)

🧩 Separate content from presentation

🛠 Make large amounts of data easy to maintain

⚠️ Handle errors and fail loudly if a file is missing

Well-designed shortcodes turn repetitive documentation patterns into reusable, expressive building blocks.

By contrast, *partials* are used for reusable rendering logic:

- Receive normalized data
- Output HTML
- Apply formatting rules
