---
type: news 
title: 💫 Own your state
date: 2023-08-22T03:48:10+02:00
featured: true
draft: true
comment: true
toc: true
reward: true
pinned: false
carousel: true
series:
  - Articles
categories:
  - Blog
tags:
  - Terraform
  - Devops
authors:
  - mozebaltyk
images: [./own-your-state/carousel.webp]
---

What if you do not want to use Terraform cloud ?...

<!--more-->

Recently I was reading this article about [Terraform Cloud](https://blog.puvvadi.me/posts/getting-started-terraform-cloud/), and remembered that I went throught same issue when writing my github Workflows...

## The issue...

When using CI, each job is a runner, so new triggered container for each step of the pipeline. So the `terraform.tfstate` is lost between the pipeline steps. In my case, I was deploying on *Digital Ocean* providers, willing to store the state on S3 bucket created for at the start of the pipeline and destroyed at the end. 


