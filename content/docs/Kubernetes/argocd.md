---
date: 2023-08-01T21:00:00+08:00
title: 🐙 ArgoCD
nav_weight: 10 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - GitOps
  - Kubernetes
---

## What is ArgoCD

[ArgoCD](https://argo-cd.readthedocs.io/) is a declarative, GitOps continuous
delivery tool for Kubernetes.

Your Git repository is the single source of truth; ArgoCD watches it and
continuously syncs the cluster to match the desired state.

```text
Git repo ──► ArgoCD ──► Kubernetes cluster
```

## Key concepts

- **Application** — a group of Kubernetes resources described in Git.
- **Project** — groups applications and scopes their permissions.
- **Source** — the repo to render from (git, helm, kustomize, …).
- **Sync** — reconcile the live cluster with the desired state.

## Install

```bash
kubectl create namespace argocd
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# expose the UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## CLI

```bash
argocd login localhost:8080

argocd app create myapp \
  --repo https://github.com/org/repo.git \
  --path deploy \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

argocd app list
argocd app sync myapp
argocd app get myapp
```

## Ops notes

- With `syncPolicy.automated` set, ArgoCD re-applies any drift on its own.
- Don't commit plaintext secrets to Git — pair ArgoCD with an external secret
  manager (Vault, sealed-secrets, SOPS/ksops).