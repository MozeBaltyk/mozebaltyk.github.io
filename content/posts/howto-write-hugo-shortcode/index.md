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
carousel: false
series:
  - Posts
categories:
  - Tutorials
tags:
  - Hugo
  - Blog
  - Golang
images:
  - ./carousel/howto-write-hugo-shortcode.avif
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

In this [posts](https://mozebaltyk.github.io/posts/howto-my-new-blog/#shortcodes), we already saw that we can use shortcode provided by the theme's modules, but let's write some customs.

## Some use cases

### Split code from the articles

On this blog, I often include large code blocks. Instead of embedding them directly in Markdown, it’s often cleaner to keep them next to the article - for example in a `code/` or `codes/` folder - and include them using a dedicated shortcode.

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

Language is taken from the file extension
```go
{{</* code-snippet example.txt*/>}} 
```

Or you can declare the language
```go
{{</* code-snippet example.txt ini*/>}}
```       
      
* The result: {{< code-snippet example.txt ini>}}  
         
{{< bs/alert warning >}}
{{< markdownify >}}
One exception: In the folder `code` do not put file with an `.html` extension, otherwise Hugo will try to build it.
{{< /markdownify >}}
{{< /bs/alert >}}

### Generate a Table from a yaml

You can generate a table from a configuration file using a shortcode. This is especially useful when you need to apply custom styling or effects, or when the dataset is large.

Instead of maintaining a long Markdown table, you can store the data in a `a-long-list-of-stuffs.yaml` file, which is easier to read and update over time.

So let do a *shortcode* which:   
✔ Generate a valid table   
✔ Auto-generates headers   
✔ Makes URLs clickable    
✔ Renders Markdown / HTML when present   
✔ Supports YAML / JSON / TOML inputs   

* The code in `./layouts/shortcodes/table-snippet.html`:

{{< code-snippet table-snippet.txt go>}} 

* The usage: `{{</* table-snippet list "name,description" */>}}`  

* The result: {{< table-snippet list "name,description" >}}

NB: here I generate HTML output, so the right syntax to use it, is `{{</* */>}}` and not `{{%/* */%}}` which is *markdown-aware*.

By then, I improved the *table-snippet* shortcode with:
✔ Uses positional parameters only
✔ Looks in *page bundle* first, then *data/*
✔ Handles nested path  *rss/my-super-list*
✔ Optional sorting arguments
✔ Optional filtering boolean arguments

* The usage now: `{{</* table-snippet DATA_FILE COLUMNS SORT FILTER */>}}`  

* Usage Example: `{{</* table-snippet rss/list "name,description,url" name active */>}}`

NB about Hugo: 
- Page bundle (local to the article/table or article/tables) = Scoped to the page
- Global data directory (data/) = Reusable across the site
- Hugo behavior is *format-agnostic configuration*, it matches all config files (`.yaml, .yml, .json, .toml` all work)

## Some ideas for future shortcodes

Here are a few additional shortcode ideas that would fit well in an IT-focused blog:

* **Diff viewer** — render configuration or code changes in a readable diff format

* **Badges** — display states such as `Active`, `Disabled`, or `Deprecated` with custom styles

* **Timelines** — visualize chronological steps, migrations, or project history

## Summary

Hugo shortcodes act as a *"controller"*. It allows you to:

📄 Keeps Markdown clean and readable

🔁 Makes data reusable across multiple posts. (Loads data *page* or *data/*)

🧩 Separates content from presentation

🛠 Makes large among of data easy to maintain

⚠️ Handles errors, Fails loudly if the file is missing

Well-designed shortcodes turn repetitive documentation patterns into reusable, expressive building blocks.

By contrast, *partials* are used for reusable rendering logic:

- Receive normalized data
- Output HTML
- Apply formatting rules