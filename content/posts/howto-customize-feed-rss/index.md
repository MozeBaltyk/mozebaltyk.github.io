---
title: "Howto Customize RSS Feed in Hugo"
description: "How to Customize in an Hugo Blogs the RSS feed and why it matters!"
date: 2026-01-20T11:15:28+01:00
draft: true
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
  - Migration
images:
#  - images/...
authors:
  - mozebaltyk
sidebar: false
---

## Some reflexions 

About the current internet, Full of Ads, scams and proselectism. 

At internet beginning, There were pasionate people willing to share knowledge and common works. 

I feel that RSS is underestimated and could be a niche to keep away from the bloated internet. 

## Let's get back to RSS feed. 

I feel that RSS is underestimated and could be reappropriated by the communities. 

- Be more selective 
- Focus on Homemade Blogs (not big corpo which try to exploit your attention)
- Avoid scrolling endlessly
- Focus on topics which really get interested to.

In two words, reappropriate internet.

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
        {{ "<" | html }}img src="https://avatars.githubusercontent.com/u/35733045?v=4" alt="Featured image for {{ .Title }}" {{ "/>" | html}}
        {{ $content }}
      </description>
    </item>
    {{- end }}
```

## Check and Validate  