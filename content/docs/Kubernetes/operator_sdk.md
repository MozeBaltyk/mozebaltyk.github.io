---
date: 2023-08-01T21:00:00+08:00
title: 🚀 Operator SDK
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Infrastructure
  - Gitops
categories:
  - Kubernetes
---


## Init an Ansible project
operator-sdk init --plugins=ansible  --domain example.org --owner "Your name"

## Create first role
operator-sdk create api --group app  --version v1alpha1 --kind Deployment --generate-role