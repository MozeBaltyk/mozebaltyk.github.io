---
# type: docs 
title: How to Create this Blog
date: 2023-08-21T02:59:46+02:00
featured: true
draft: false
comment: true
toc: true
reward: true
pinned: true
carousel: true
series:
  - News
categories:
  - Blog
tags: 
  - Hugo
  - Git
  - Hosting
authors:
  - mozebaltyk
images: [./how-to-create-this-blog/carousel.webp]
---


When prospecting about creating my Blog; I went throught the normal questions that everybody have.   
Here are my thoughts and what I learnt...

<!--more-->

In short, here the few questions I went through. By the way, Probably you can notice that those questions go from theory to practice.
  - Why ?
  - Where ?
  - Which Techno ?
  - Which Theme ?


# Why ?

Why would you like a blog ? Search with google "Why would you like a blog" will lead you to conclusion that is good for your bisness. You need to be visible on the net to increase you credibility as an expert and so on. Nonetheless, I was recently listening a guy on Youtube who critized blogs for good reasons. Everybody is doing it. At the end, everybody start it but nobody keep up writing articles. It ends looking as a poor vitrin of yourself, and for good reasons, if you do not fuel your blog with regular new articles. Anyway; this guy end up showing some interestind blogs with unexpected content and remember us that it's still worth it. And you are bloging ?    

So in my case, first it's an exercice. Due to my IT job, I need to see how does it work. What are the possibilities and techno available for it. Second, I wanted a place with multiple purpose. A place for article about my though like this one but also a place to centralize my documentation.Longtime ago, when I started in IT and did not know what I was doing and I simply took notes in OneNote. For technical notes, that's not the best. No versioning, no code highlight, and proprietary software. Sharing some notes, also ask extra effort to export in word before to send. Along the years, my personal notes were growing and always. First I add the idea to move everything in markdown have an mdBook, but that's would only for a documentation solution... 


# Where to host the Blog ?
 
Of course, I first thought about self hosting on VPS but to much hassle when there is much easier options. Like Hubspot 


## Which techno to use ?

Working with Hugo is pretty convenient, you draft your article then launch `hugo server -D` so you can see in your browser how looks your blog with all draft articles.

## Which super theme to use ?

Understand the terms: 

- series
- categories
- tags
- featured


## Prerequisites

As prerequisites, we need Nodejs, npm, GO, dart SASS, and Hugo extended version as describe [here](https://hbs.razonyang.com/v1/en/docs/getting-started/prerequisites/#build-tools):    

```bash 
# Install nodejs and npm 
sudo apt install nodejs npm

# Install GO
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Install DART SASS 
DART_SASS_VERSION="1.66.1"
curl -LJO https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz
tar -xf dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz
sudo cp -r dart-sass/* /usr/local/bin 
rm -rf dart-sass*

# Install Hugo source
HUGO_VERSION="0.117.0"
curl -LJO https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb
sudo apt install -y ./hugo_extended_${HUGO_VERSION}_linux-amd64.deb

hugo version                                                                                                                            
hugo v0.117.0-b2f0696cad918fb61420a6aff173eb36662b406e+extended linux/amd64 BuildDate=2023-08-07T12:49:48Z VendorInfo=gohugoio
```

To be fair, you could also do it with `snap`:     

```bash
$ sudo snap install dart-sass

$ sudo snap install hugo

$ which hugo
/snap/bin/hugo

$ hugo version
hugo v0.117.0-b2f0696cad918fb61420a6aff173eb36662b406e+extended linux/amd64 BuildDate=2023-08-07T12:49:48Z VendorInfo=snap:0.117.0
``` 

## Creating the Project 

```bash 
$ cd myblog
$ git submodule add https://github.com/razonyang/hugo-theme-bootstrap themes/hugo-theme-bootstrap
$ git clone https://github.com/razonyang/hugo-theme-bootstrap-skeleton /tmp/hbs-skeleton
$ mkdir config
$ cp -a /tmp/hbs-skeleton/config/* ./config
$ cp -r /tmp/hbs-skeleton/content/* ./content
$ cp -r /tmp/hbs-skeleton/archetypes/* ./archetypes
$ cp -r /tmp/hbs-skeleton/static/* ./static
$ cp -r /tmp/hbs-skeleton/assets/* ./assets
$ sed -i "s/theme:.*/theme: hugo-theme-bootstrap/g" config/_default/config.yaml
$ hugo mod npm pack
$ npm install
$ hugo server
```


## Publish it with Github Pages


## Settings


## A word on giscus

In config/default/params.yaml, there is a bloc on giscus config, a comments system powered by GitHub Discussions, so the comments left on your articles goes in discussions of your github Pages.  

So to do so, you will need to:
- make your repoistory public.
- enable [discussions](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/enabling-or-disabling-github-discussions-for-a-repository) in the porject settings.
- activate [giscus app](https://github.com/apps/giscus) for on your account (you can limit to your blog project)
- Then, giving the URL of your repository

After custom config, on my case I left everything by default, you got a block of xml values that you can reuse in the config/default/params.yaml of your Hugo Blog. 

```yaml
# See https://giscus.app
giscus:
  repo: "MozeBaltyk/mozebaltyk.github.io" # required.
  repoId: "R_kgDOKJSCfA" # required. R_kgDOKJSCfA
  category: "General" # required.
  categoryId: "DIC_kwDOKJSCfM4CYvA_" # required.
  theme: "dark" # Default to auto.
```

On their side, visitors will need a Github account and must authorize the giscus app to post on their behalf using the GitHub OAuth flow. 


## Edit Articles 

Simple way to do an article (one folder by articles):
```bash
hugo new news/new-post/index.md
hugo new news/new-post/index.fr.md
hugo new news/new-post/index.pl.md
```

Several articles in one folder (one _index.md + all articles):
```bash
vi docs/Devops/Containers/_index.md
hugo new docs/Devops/Containers/docker.md
hugo new docs/Devops/Containers/podman.md
```

Please remind that, the created posts are generally in draft state. You’ll need to specify the `-D` parameter of the command hugo server for previewing.           
Similarly, you need to change the draft to false or remove draft parameter if you want to publish the article.


## Deployment

The deployement of this blog is done by Github Wokflow. Here, you can adopt several strategy.  

I started with everytime I was pushing it deploy, which give me no time after saving to read again my articles. Then I put it on `workflow_dispatch`, which means only when I manully trigger the workflow to build, but I think that the proper way to do, is to developp on a branch and deploy only when the branch is merge. 

Here is how

## Sources: 
See also documentation of this [Awesome Hugo theme](https://hbs.razonyang.com/v1/en/docs/getting-started/prerequisites/). 

See also [README of this theme](https://github.com/razonyang/hugo-theme-bootstrap-skeleton/blob/main/README.md).   

See also [Deployment of this theme](https://hbs.razonyang.com/v1/en/docs/deployment/github-pages/).     

See also [Github Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow).    
