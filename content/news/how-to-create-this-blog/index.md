---
# type: docs 
title: How to Create this Blog
date: 2023-08-21T02:59:46+02:00
featured: true
draft: false
comment: true
toc: true
reward: true
pinned: false
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

In short the few questions I went through:
  - Why ?
  - Where ?
  - Which Techno ?
  - Which Theme ?

Probably you can notice that those questions go from theory to practice. 

### Why ?
Why would you like a blog ? Looking at "Why would you like a blog" will lead you to conclusion that is good for your bisness. You need to be visible on the net to increase you .  Recently, I was listening a guy on Youtube which critized the 

### Where to host the Blog ?
 
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


## Edit Articles 

```bash
 hugo new news/new-post/index.md
 hugo new news/new-post/index.fr.md
 hugo new news/new-post/index.pl.md
```

Please remind that, the created posts are generally in draft state. You’ll need to specify the `-D` parameter of the command hugo server for previewing.           
Similarly, you need to change the draft to false or remove draft parameter if you want to publish the article.


## Deployment


## Sources: 
See also documentation of this [Awesome Hugo theme](https://hbs.razonyang.com/v1/en/docs/getting-started/prerequisites/). 

See also [README.md](https://github.com/razonyang/hugo-theme-bootstrap-skeleton/blob/main/README.md).   

See also [Deployment](https://hbs.razonyang.com/v1/en/docs/deployment/github-pages/).     

See also [Deployment](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow).    