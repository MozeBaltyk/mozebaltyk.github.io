---
date: 2023-08-01T21:00:00+08:00
title: 🚀 Operator SDK
nav_weight: 110 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Kubernetes
  - IaC
---

## What is an Operator

A controller is a loop that watches Kubernetes objects and reconciles their
**desired state** (the spec) with the **actual state** (the cluster).

An **Operator** is a controller with operational knowledge baked in: it knows
how to install, configure, scale, back up and upgrade an application — the jobs
a human admin used to do by hand.

```text
desired state (CR)  ──►  reconcile loop  ──►  actual state (cluster)
```

Classic examples: `etcd-operator`, `prometheus-operator`.

## What Operator SDK provides

Writing that reconcile loop by hand means a lot of boilerplate: CRDs, client
code, RBAC, controller scaffolding, watch wiring. Operator SDK (from the
Operator Framework) automates it:

- `operator-sdk init` — scaffold the Go module, `Makefile`, `Dockerfile` and
  `config/` (CRDs, RBAC, manager, samples).
- `operator-sdk create api` — generate the CRD type + the controller that
  watches it.
- RBAC markers and a ready-made reconcile skeleton, so you only write the
  business logic.

## The three kinds

Operators have 3 kinds: Go, Ansible, Helm.

| Kind | How the logic is written | Best when |
|---|---|---|
| **Go** | reconcile loop in Go (client-go) | complex, performant, custom logic |
| **Ansible** | roles/playbooks via ansible-runner | existing Ansible automation |
| **Helm** | wraps a Helm chart | deploy a known chart declaratively |

`watches.yaml` maps a given CR to the Ansible role/playbook that must run when
an object of that kind appears.

## Init an Ansible operator

```bash
# Init an Ansible project
operator-sdk init --plugins=ansible --domain example.org --owner "Your name"
```

The command creates the following structure:

```text
netbox-operator
├── Dockerfile
├── Makefile
├── PROJECT
├── config
│   ├── crd
│   ├── default
│   ├── manager
│   ├── manifests
│   ├── prometheus
│   ├── rbac
│   ├── samples
│   ├── scorecard
│   └── testing
├── molecule
│   ├── default
│   └── kind
├── playbooks
│   └── install.yml
├── requirements.yml
├── roles
│   └── deployment
└── watches.yaml
```

## Create a CRD / API

```bash
# Create the first API and generate the role
operator-sdk create api --group app --version v1alpha1 --kind Deployment --generate-role
```