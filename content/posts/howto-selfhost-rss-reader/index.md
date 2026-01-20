---
title: "📻 How to Selfhost a RSS Reader"
description: "Launch a RSS Reader to follow blogs that you like"
date: 2026-01-21T16:00:00+01:00
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
  - Blog
  - OpenSources
  - RSS
images:
  - ./carousel/howto-selfhost-rss-reader.jpg
authors:
  - mozebaltyk
sidebar: false
---

## What for ?

In the IT world, staying up to date is not optional — it is part of the job. New tools, security issues, best practices, and architectural patterns evolve constantly, and missing key information can quickly lead to outdated knowledge or poor decisions. This ongoing process of monitoring and learning is often referred to as veille.

Despite being one of the oldest formats on the web, technical blogs remain one of the most interesting source of knowledge. They are written by practitioners, focused on real problems, and usually free from the noise that dominates modern platforms.

Unfortunately, today’s internet is increasingly polluted by aggressive advertising, clickbait headlines, and auto-generated content optimized for engagement rather than accuracy. Finding high-quality articles has become harder, and relying on centralized platforms means giving up control over what you see and when you see it.

This post is not about writing or publishing content — it is about reading it. More specifically, it is about taking back control of your information flow by self-hosting an RSS reader. By doing so, you can build a curated, distraction-free reading environment centered around the blogs and authors you trust. 

## Which one?

Now that we understand why taking control of our reading environment matters, the next question is: which RSS reader should you use?

There are many open-source RSS readers available, each with its own strengths and trade-offs. Some focus on simplicity, others on collaboration, others on self-hosting friendliness or extensibility. Choosing the right one depends on your priorities — performance, UI, multi-device sync, or integrations with other services.

Below is a curated list of notable open-source RSS readers, along with their main advantages to help you make an informed choice.

Below, Open-source RSS readers worth considering.

### 📰 FreshRSS

**Description**: A lightweight, web-based RSS reader written in PHP.

**Pros**:

- Easy to install on most shared hosts or containers.

- Clean, responsive UI.

- Supports multiple users and categories.

- Good performance even with large feed collections.

- Has a mobile-friendly interface.

**Best for**: Users who want a simple, self-hostable web reader with solid performance.

### 🐙 Miniflux

**Description**: A minimalist, fast, and reliable RSS reader written in Go.

**Pros**:

- Extremely lightweight and fast.

- Minimal dependencies.

- Clean, distraction-free interface.

- Supports filters and rules (e.g., auto-mark read based on keywords).

- Works great in Docker or with a small VPS.

**Best for**: Users who prioritize simplicity and speed over feature bloat.

### 🌈 FreshRSS + Extensions

**Description**: FreshRSS can be extended with plugins and themes.

**Pros**:

- Customizable experience.

- Extensions for better article handling, themes, and more.

- Good compromise between simplicity and features.

**Best for**: Users who want more customization without switching platforms.

### 🚀 CommaFeed

**Description**: A Java-based RSS reader inspired by Google Reader.

**Pros**:

- Supports OPML import/export.

- Clean reader UI.

- Can run as a standalone service.

- Has a “River of News” mode for quick scan.

**Best for**: Users migrating from legacy readers who want a familiar style.

### 🧩 Tiny Tiny RSS

**Description**: A robust, extensible RSS reader written in PHP.

**Pros**:

- Very powerful and feature-rich.

- Plugins for themes, filters, and integrations.

- Supports multiple users and roles.

- Active community with many extensions.

**Cons**:

- Heavier than alternatives — may need more resources.

**Best for**: Users who want a full-featured RSS platform with advanced capabilities.


## How to choose ?

{{< table-snippet rss-readers "name,ram,cpu,lightweight,extensible,selfhost,best_for" >}}

## FreshRSS - The Chosen one

I hesitate between *FreshRSS* and *Tiny Tiny RSS*, But the first one seems more user friendly and largely supported.

* The quick run - to test it on the fly:

```sh
podman run -d --restart unless-stopped --log-opt max-size=10m \
  -p 8080:80 \
  -e TZ=Europe/Paris \
  -e 'CRON_MIN=1,31' \
  -v freshrss_data:/var/www/FreshRSS/data \
  -v freshrss_extensions:/var/www/FreshRSS/extensions \
  --name freshrss \
  docker.io/freshrss/freshrss
```

* In [FreshRSS Docker doc](https://github.com/FreshRSS/FreshRSS/blob/edge/Docker/README.md):

```yaml
FRESHRSS_INSTALL: automatically pass arguments to command line cli/do-install.php (for advanced users; see example in Docker Compose section). Only executed at the very first run (so far), so if you make any change, you need to delete your freshrss service, freshrss_data volume, before running again.
FRESHRSS_USER: automatically pass arguments to command line cli/create-user.php (for advanced users; see example in Docker Compose section). Only executed at the very first run (so far), so if you make any change, you need to delete your freshrss service, freshrss_data volume, before running again.
```
     
So let's convert it as *systemd* services...     

* Create an env file `~/.config/freshrss/freshrss.env`

{{< code-snippet freshrss.env >}}

* Create service file for our Standalone App in `$HOME/.config/containers/systemd/freshrss-app.service`    

{{< code-snippet freshrss-app.service ini>}}

* and `freshrss-net.service`

{{< code-snippet freshrss-net.service ini>}}

* Validate the service and start it:

```bash
systemd-analyze --user verify freshrss-app.service
systemctl --user daemon-reload
systemctl --user start freshrss-app
journalctl --user -u freshrss-app -f
```

{{< bs/alert warning >}}
{{< markdownify >}}
If you change any of these:
- FRESHRSS_INSTALL
- FRESHRSS_USER
- admin passwords
- base URL
    
Volume need to be deleted and freshrss-app restarted.   
{{< /markdownify >}}
{{< /bs/alert >}}

```bash
# Stop and remove
systemctl --user stop freshrss-app
podman stop freshrss-app
podman rm -f freshrss-app
# Remove volumes
podman volume rm freshrss_data freshrss_extensions
# Checks
podman volume ls
# Restart
systemctl --user restart freshrss-app
```

## List of blogs that I would like to follow

{{< table-snippet "rss/blogs" "name,description,url" "name" "active">}}

## Bonuses

* [Polish and customize RSS feed](https://mozebaltyk.github.io/posts/howto-customize-feed-rss/) 

* 🛸 RSS-Hub (feeder + aggregator)

**Description**: A powerful aggregator for creating RSS feeds from sites that don’t offer them.

**Pros**:

- Generates feeds for sites with no native RSS.

- Works with many services via rules.

- Can pair with any RSS reader.

**Best for**: When feeds are missing or poor and you need custom sources.

## Sources
- FreshRSS [deploy with docker](https://github.com/FreshRSS/FreshRSS/tree/edge/Docker)
- FreshRSS [Doc](https://freshrss.github.io/FreshRSS/en/)
- Korben on [RSS topic](https://korben.info/rsshub-rss-flux-sites-aaron-swartz.html)
- Nice RSS optimization from [Romain Blog](https://blog.laromierre.com/posts/how-to-customize-and-optimize-your-hugo-rss-feed/)
