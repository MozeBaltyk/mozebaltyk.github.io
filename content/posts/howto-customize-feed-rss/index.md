---
title: "🔔 Customize RSS Feed in Hugo"
description: "How to Customize in an Hugo Blogs the RSS feed and why it matters!"
date: 2026-01-20T11:15:28+01:00
draft: false
noindex: false
featured: true
pinned: false
comment: true
toc: true
reward: true
carousel: true
series: 
  - Posts
categories:
  - Tutorials
tags:
  - Blog
  - Hugo
  - RSS
images:
  - ./carousel/howto-customize-feed-rss.avif
authors:
  - mozebaltyk
sidebar: false
---

## Some human reflections

The current internet is full of ads, scams, and proselytism. This phenomenon even has a name: **“enshittification”**, a term coined by Cory Doctorow.

At the beginning of the internet, there were passionate people willing to share knowledge and collaborate on common projects. The web felt more human, more normal.

Today, attention has become a resource to be extracted. Platforms are optimized for engagement, not understanding. Content is buried under advertising, dark patterns, and algorithmic noise.

In this context, I feel that RSS is underestimated — and that it could be a niche, or even a refuge, from this bloated, advertising-driven internet.

## Let’s get back to RSS feeds

RSS feels outdated to many, yet it remains one of the most elegant tools the web has ever produced. It is simple, decentralized, and user-controlled.

I believe RSS could be reclaimed by communities. Here are a few arguments:

* **Selective consumption**: you choose the topics that genuinely interest you.
* **Homemade blogs first**: not big corporations trying to monetize your attention.
* **No endless scrolling**: you read what’s new, then you stop.
* **Peer-to-peer knowledge**: direct connections between writers and readers.
* **Simple user experience**: no FOMO, no forced continuity, no social-proof mechanics.

RSS doesn’t try to hook you. It doesn’t rank, recommend, or manipulate. It simply delivers content you explicitly asked for.

So let’s take care of our feeds — and maybe, by doing so, take care of the web a little too.

## Config customization

All the RSS config are done in `.config/hugo.yaml`

* Limit the number of articles in your RSS feed to not overwhelm the feed. 
```yaml
services:
  RSS:
    limit: 10
```

* Change the default `index.xml` to `feed.xml` and produce only one feed

```yaml
# Change the default index.xml to feed.xml
outputFormats:
  RSS:
    mediatype: "application/rss"
    baseName: "feed"    

outputs:
  home:
    - HTML
    - Offline        # required by PWA module for displaying the offline pages.
    - RSS
    - SearchIndex    # required by search module.
    - WebAppManifest # required by PWA module to make your site installable.
  # default outputs for other kinds of pages (avoid produce RSS unecessarily).
  section: ['html']
  taxonomy: ['html']
  term: ['html']
```

## Customize the output 

To customize the XML of your RSS feed, you need to override the default template. For this, create a file named `layouts/_default/rss.xml` with the [default Hugo rss.xml](https://github.com/gohugoio/hugo/blob/master/tpl/tplimpl/embedded/templates/rss.xml), then adapt it.    

For example in my case - display just type "page" (not the Categories, Authors, etc ) and only "posts" section, then I diplay the full content with my Github avatar as front image (since I do not have regular name for each post):

```xml
    {{- range where (where .Site.Pages ".Section" "posts") "Kind" "page" }}
    <item>
      <title>{{ .Title }}</title>
      <link>{{ .Permalink }}</link>
      <pubDate>{{ .PublishDate.Format "Mon, 02 Jan 2006 15:04:05 -0700" | safeHTML }}</pubDate>
      {{- with $authorEmail }}<author>{{ . }}{{ with $authorName }} ({{ . }}){{ end }}</author>{{ end }}
      <guid>{{ .Permalink }}</guid>
      {{- $content := safeHTML (.Content | html) -}}
      <description>
        {{- with index .Params.images 0 }}
          {{- $imageURL := printf "%s%s" $.Site.BaseURL . | absURL }}
          {{ "<" | html }}img src="{{ $imageURL }}" 
            alt="Featured image for {{ $.Title }}" 
            width="600" height="400" 
          {{ "/>" | html }}
        {{- end }}
        {{ $content }}
      </description>
    </item>
    {{- end }}
```

Nice RSS optimization from [Romain Blog](https://blog.laromierre.com/posts/how-to-customize-and-optimize-your-hugo-rss-feed/) which also remember some basic facts: 

> Beyond standard feed readers, a clean RSS feed is the backbone of automated newsletters. 
> Tools like **Mailchimp**, **ConvertKit**, or **MailerLite** have features called *“RSS-to-Email”*.


## Check and Validate

* Validate RSS feed with [W3C Feed Validation Service](https://validator.w3.org/feed/).

* Check with a RSS reader like *FeedDesk* for Windows or *FreshRSS* for Linux users the final output. 

* Find RSS feed from a blog [here](https://www.rsslookup.com/)

## Bonus

🐍 Here is the bonus, a python script to convert a *yaml* file to *OPML* file that I can import it in my *feedDesk*.

{{< code-snippet yaml-to-opml.py>}}

It takes a *yaml* file with this structure: 

```yaml
# Name; URL; description; feed; active (true/false)
- name: Bałtyk Blog
  url: https://mozebaltyk.github.io/
  feed: https://mozebaltyk.github.io/feed.xml
  description: My personal blog about sysadmin and devops topics.
  active: false
- name: While True Do
  url: https://blog.while-true-do.io/
  feed: https://blog.while-true-do.io/rss/
  description: A blog about programming, technology, and software development.
  active: true
```