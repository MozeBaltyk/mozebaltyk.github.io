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

Operators have 3 kinds : go, ansible, helm. 

```bash
## Init an Ansible project
operator-sdk init --plugins=ansible  --domain example.org --owner "Your name"

## Command above will create a structure like:
netbox-operator
├── Dockerfile
├── Makefile
├── PROJECT
├── config
│   ├── crd
│   ├── default
│   ├── manager
│   ├── manifests
│   ├── prometheus
│   ├── rbac
│   ├── samples
│   ├── scorecard
│   └── testing
├── molecule
│   ├── default
│   └── kind
├── playbooks
│   └── install.yml
├── requirements.yml
├── roles
│   └── deployment
└── watches.yaml
```

```bash
## Create first role
operator-sdk create api --group app  --version v1alpha1 --kind Deployment --generate-role
```
