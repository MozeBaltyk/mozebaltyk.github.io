---
title: "📻 How to Selfhost a RSS Reader"
description: "Launch and host RSS Reader to follow blogs that you like"
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

## Why RSS?

In the IT world, staying up to date is not optional — it is part of the job.

New tools appear constantly, security issues are discovered, best practices evolve, and architectural patterns come and go. Missing important information can quickly lead to outdated knowledge or poor technical decisions.

This ongoing process of monitoring, reading, and learning is often referred to in French as *veille technologique*. In English, we might simply call it **keeping up with technology** or **technology monitoring**.

Despite being one of the oldest formats on the web, RSS remains one of my favorite ways to do this.

Technical blogs are still an excellent source of knowledge. They are often written by practitioners, focused on real-world problems, and provide much more depth than a short social media post.

Unfortunately, today's web is increasingly filled with aggressive advertising, clickbait headlines, tracking, recommendation algorithms, and automatically generated content optimized for engagement rather than usefulness.

Finding high-quality information is becoming harder.

Relying exclusively on centralized platforms also means giving up control over what you see, how it is sorted, and when it appears.

RSS takes the opposite approach:

**you choose the sources.**

There is no recommendation algorithm deciding what deserves your attention. You subscribe to the blogs and authors you trust, and their articles arrive in your reader.

This post is therefore not about writing or publishing content.

It is about **reading it**.

More specifically, it is about taking back control of my information flow by self-hosting an RSS reader and building a curated, distraction-free environment around the blogs and authors I want to follow.

## Which RSS reader?

Once we decide to self-host an RSS reader, the next question is obvious:

**Which one should we use?**

There are many open-source RSS readers available, each with different priorities.

Some focus on simplicity and performance. Others provide extensive filtering, plugins, integrations, or multi-user support.

The right choice depends on what matters most to you:

- Performance
- Resource consumption
- User interface
- Mobile compatibility
- Multi-device synchronization
- Filtering capabilities
- Extensibility
- Ease of deployment
- Ease of maintenance

Here are a few interesting candidates.

### 📰 FreshRSS

**Description:** A lightweight, self-hosted, web-based RSS and Atom aggregator written in PHP.

**Pros:**

- Easy to deploy
- Clean and responsive web interface
- Multi-user support
- Categories, filters, and search
- OPML import and export
- Extensions and themes
- Mobile-friendly interface
- Compatible with several mobile applications through its APIs
- Works well with large collections of feeds

**Best for:** Users looking for a mature, flexible, and easy-to-self-host RSS reader.

### 🐙 Miniflux

**Description:** A minimalist and opinionated RSS reader written in Go.

**Pros:**

- Very lightweight
- Fast
- Minimal dependencies
- Clean and distraction-free interface
- Powerful filtering rules
- Full-text content extraction
- OPML import and export
- REST API
- Easy container deployment

One important consideration is that Miniflux requires PostgreSQL, which means deploying an additional service compared with a simple SQLite-based installation.

**Best for:** Users who prioritize simplicity, performance, and a minimalist interface.

### 🚀 CommaFeed

**Description:** A self-hosted RSS reader inspired by Google Reader.

**Pros:**

- Familiar Google Reader-style interface
- OPML import and export
- Keyboard-oriented navigation
- Clean reading interface
- Self-hostable

**Best for:** Users looking for an experience similar to the old Google Reader.

### 🧩 Tiny Tiny RSS

**Description:** A powerful and extensible web-based RSS and Atom reader.

**Pros:**

- Feature-rich
- Flexible filtering
- Plugin support
- Themes
- OPML import and export
- API
- Full-article extraction
- Feed organization using folders and subfolders
- Self-hosted

**Cons:**

- More complex than some alternatives
- The officially recommended deployment model is based on containers
- Can require more administration than simpler readers

**Best for:** Users looking for a highly configurable RSS platform with advanced capabilities.

## How to choose?

I maintain a small comparison table to make the differences easier to visualize:

{{< table-snippet rss-readers "name,ram,cpu,lightweight,extensible,selfhost,best_for" >}}

The goal is not necessarily to identify a universal "best" RSS reader.

It is to find the one that best matches my own requirements.

In my case, I want something that is:

- Open source
- Easy to self-host
- Lightweight
- Web-based
- Mobile-friendly
- Mature and actively maintained
- Easy to back up
- Easy to redeploy

## FreshRSS — the chosen one

I hesitated mainly between **FreshRSS** and **Tiny Tiny RSS**.

Both are mature projects with many features, but FreshRSS looks simpler to deploy and maintain for my needs. Its interface is also straightforward, and it has broad support for external clients and integrations.

So, let's deploy FreshRSS.

### Quick test

Before creating a persistent service, we can start by running the container directly.

Using Podman:

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

FreshRSS should then be available on:

```text
http://localhost:8080
```

The two volumes keep the important state outside the container:

```text
freshrss_data
freshrss_extensions
```

This means the container itself remains disposable.

That is exactly what I want.

## Automating the initial configuration

FreshRSS provides two particularly useful environment variables for automated deployments:

```text
FRESHRSS_INSTALL
FRESHRSS_USER
```

From the [FreshRSS Docker documentation](https://github.com/FreshRSS/FreshRSS/blob/edge/Docker/README.md):

`FRESHRSS_INSTALL` passes arguments to the FreshRSS installation CLI.

`FRESHRSS_USER` passes arguments to the user creation CLI.

These options allow us to bootstrap the instance without manually walking through the web installer.

There is one important detail, however:

these values are intended for the **initial installation**.

Changing them later does not automatically reconfigure an existing FreshRSS data directory.

That distinction becomes important when we turn the container into a reproducible service.

## Running FreshRSS with Podman and systemd

A manually executed `podman run` command is useful for testing, but I do not want to start the application manually after every reboot.

Instead, I want systemd to manage the container.

For rootless Podman, Quadlet files can be stored in:

```text
~/.config/containers/systemd/
```

Rather than manually writing a generated systemd service, we can describe the container and let Podman generate the corresponding systemd units.

### Environment configuration

First, create:

```text
~/.config/freshrss/freshrss.env
```

{{< code-snippet freshrss.env >}}

This keeps the environment configuration outside the Quadlet definition and makes the service easier to maintain.

Be careful with secrets stored in this file, especially the initial administrator password.

Appropriate file permissions should be applied:

```bash
chmod 600 ~/.config/freshrss/freshrss.env
```

### FreshRSS container

Create the container definition:

```text
~/.config/containers/systemd/freshrss-app.container
```

{{< code-snippet freshrss-app.container ini>}}

Podman Quadlet will use this file to generate the corresponding:

```text
freshrss-app.service
```

### FreshRSS network

If a dedicated network is required, create:

```text
~/.config/containers/systemd/freshrss-net.network
```

{{< code-snippet freshrss-net.network ini>}}

The network is then also managed by Podman through systemd.

This approach keeps the container definition declarative while letting systemd handle its lifecycle.

## Validate and start FreshRSS

Reload the user systemd configuration:

```bash
systemctl --user daemon-reload
```

Then inspect the generated unit:

```bash
systemctl --user status freshrss-app.service
```

Start FreshRSS:

```bash
systemctl --user start freshrss-app.service
```

Follow the logs:

```bash
journalctl --user -u freshrss-app.service -f
```

And enable it if we want FreshRSS to start automatically:

```bash
systemctl --user enable --now freshrss-app.service
```

For rootless user services that must continue running without an interactive login session, `linger` may also be required:

```bash
loginctl enable-linger "$USER"
```

## Reinitializing FreshRSS

{{< bs/alert warning >}}
{{< markdownify >}}

Variables such as:

- `FRESHRSS_INSTALL`
- `FRESHRSS_USER`

are primarily used during the initial FreshRSS setup.

Changing the initial administrator account, installation parameters, or related bootstrap settings does not necessarily modify an already initialized instance.

If the goal is to completely recreate the instance from scratch, the FreshRSS data volume must also be removed.

**Deleting the data volume destroys the FreshRSS configuration and local application data, so make sure anything important has been backed up first.**

{{< /markdownify >}}
{{< /bs/alert >}}

For a complete reset:

```bash
systemctl --user stop freshrss-app.service
```

Check the existing containers and volumes:

```bash
podman ps -a
podman volume ls
```

Remove the FreshRSS data volumes:

```bash
podman volume rm freshrss_data freshrss_extensions
```

Then start the service again:

```bash
systemctl --user restart freshrss-app.service
```

Follow the initialization:

```bash
journalctl --user -u freshrss-app.service -f
```

The important idea here is that the **container is disposable, while the volume contains the persistent application state**. Currently I deploy FreshRSS on my workstation, but future target would be to deploy it on a homelab kubernetes cluster.  

## My technology watch

Running an RSS reader is only half of the story.

The interesting part is deciding **what to put inside it**.

I maintain my own curated list of technical blogs and other sources that I want to follow.

{{< table-snippet "rss/blogs" "name,description,url" "name" "active">}}

I use this blog repository itself as the source of truth for my RSS source list.

The list is stored in:

```text
./data/rss/blogs.yaml
```

and rendered in the table above.

I like this approach because my reading list becomes part of my configuration.

It is:

- Version controlled
- Easy to review
- Easy to share
- Easy to restore
- Independent from the RSS reader itself

FreshRSS manages the reading experience, while Git keeps the authoritative list of sources I care about.

That also fits the philosophy I apply to the rest of my tooling:

**applications can be replaced; configuration should remain reproducible.**

## Other projects to explore

RSS readers continue to evolve, so there are a few newer projects I would also like to investigate.

### 🤖 MrRSS

[MrRSS](https://korben.info/en/mrrss-rss-reader-ai-summary-translation.html) is an open-source desktop RSS reader with built-in AI features for summarizing and translating articles.

It is an interesting approach for large technology-watch collections, where quickly deciding which articles deserve a deeper read can become difficult.

I still prefer a self-hosted web application for my primary reader, but MrRSS is worth keeping an eye on.

### 👾 RSSMonster

[RSSMonster](https://korben.info/en/rssmonster-rss-reader-sorts-feeds-locally.html) takes another interesting approach.

Instead of simply presenting articles chronologically, it can group articles dealing with similar subjects and rank them locally.

That could be particularly useful when several technical blogs report on the same announcement or security issue.

Again, this solves a slightly different problem from FreshRSS, but it is an interesting direction to explore.

## Bonus: when a website has no RSS feed

Not every website provides a good RSS feed.

Sometimes there is no feed at all.

That is where projects such as **RSSHub** become useful.

### 🛸 RSSHub

**Description:** An open-source project that can generate RSS feeds for websites and services that do not provide useful native feeds.

**Pros:**

- Generates feeds for sites without RSS support
- Supports many websites and services through predefined routes
- Can be self-hosted
- Works with any normal RSS reader
- Complements rather than replaces FreshRSS

**Best for:** Adding sources that do not provide usable RSS or Atom feeds themselves.

The architecture becomes:

```text
Website
   │
   ▼
 RSSHub
   │
   ▼
 RSS feed
   │
   ▼
FreshRSS
```

FreshRSS remains the reader.

RSSHub simply gives it more sources to consume.

## Conclusion

RSS may be old technology, but that is not a disadvantage.

It is simple, open, decentralized, widely supported, and does not require a recommendation algorithm to work.

For technology monitoring, that is almost exactly what I want.

My goal is not to consume as much information as possible.

It is to build a **small, curated information stream made of sources I deliberately chose**.

FreshRSS provides the reading interface.

Podman and systemd make the deployment reproducible.

Git stores my curated list of sources.

And tools such as RSSHub can fill the gaps when websites do not expose feeds themselves.

The result is a personal technology-watch system that I control from end to end.

No algorithm deciding what I should read.

No dependency on a single centralized platform.

Just websites publishing content, RSS connecting them together, and my own reader deciding what enters my inbox.

Sometimes, old and boring technology is exactly what we need.

## Sources

- [FreshRSS documentation](https://freshrss.github.io/FreshRSS/en/)
- [FreshRSS Docker deployment](https://github.com/FreshRSS/FreshRSS/tree/edge/Docker)
- [Miniflux](https://miniflux.app/)
- [Tiny Tiny RSS](https://tt-rss.org/)
- [Podman Quadlet documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
- [Korben — RSS topics](https://korben.info/rsshub-rss-flux-sites-aaron-swartz.html)
- [Korben — RSS is Life](https://korben.info/en/rss-feeds-are-life.html)