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
  - GitHub
  - Blog
authors:
  - mozebaltyk
images: ['how-to-create-this-blog.webp']
---


When prospecting about creating my Blog; I went throught the normal questions that everybody have.    
Here were my thoughts and what I learnt...

<!--more-->

In few Questions: 
  - Where to host the Blog ?
  - Which Techno to use ?
  - Which super Theme to use ?

## Edit Articles 

```bash
 hugo new news/new-post/index.md
 hugo new news/new-post/index.fr.md
 hugo new news/new-post/index.pl.md
```

Please remind that, the created posts are generally in draft state. You’ll need to specify the `-D` parameter of the command hugo server for previewing. Similarly, you need to change the draft to false or remove draft parameter if you want to publish the article.

## Sources: 
See also documentation of this [Awesome Hugo theme](https://hbs.razonyang.com/v1/en/docs/getting-started/prerequisites/). 

See also [README.md](https://github.com/razonyang/hugo-theme-bootstrap-skeleton/blob/main/README.md).   

See also [Deployment](https://hbs.razonyang.com/v1/en/docs/deployment/github-pages/).     

See also [Deployment](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow).    