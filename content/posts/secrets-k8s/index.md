--- 
title: 💫 Secrets in kubernetes
description: "A practical guide to generating, reusing, and externalizing secrets in Kubernetes."
date: 2026-01-15T03:48:10+02:00
draft: true
noindex: false
featured: true
comment: true
toc: true
reward: true
pinned: false
carousel: true
series:
  - Posts
categories:
  - Devops
tags:
  - Containers
  - Devops
  - Secrets
  - Kubernetes
authors:
  - mozebaltyk
images: 
  - ./carousel/fog-on-lake.jpg
sidebar: false
---

## Introduction

Kubernetes makes it very easy to create a `Secret`, but that does not automatically mean your secret handling is good.

A `Secret` object is still just data stored in the cluster API. By default it is **base64-encoded, not encrypted**. The real protection comes from:

- RBAC
- etcd encryption at rest
- namespace isolation
- not leaking values in Git, CI logs, or Helm output

So the question is not only *how do I create a secret?* but rather *where should the source of truth live?*

In practice I use three levels:

1. Let Helm generate a value when the application only needs an internal password.
2. Reuse the existing value on upgrades so the chart stays stable.
3. Move to an external tool when the secret must be shared, audited, rotated, or stored outside the cluster.

<!--more-->

## The naive Helm pattern

The most direct approach is to generate a random value inside the chart:

```yaml
{{- define "mychart.password" -}}
{{- randAlphaNum 32 | quote -}}
{{- end -}}
```

Then in the template:

```yaml
password: {{ include "mychart.password" . }}
```

This works, but it has one big problem: it generates a new random value every time Helm renders the template.

That means a plain `helm upgrade` can rotate credentials even when you did not want rotation at all. For a database password, an admin token, or any value reused by another workload, that is usually the wrong behavior.

This pattern is only acceptable when the value is truly disposable.

## A better Helm pattern with `lookup`

Usually what we want is:

- generate the secret on first install
- keep it on upgrades
- regenerate only if the secret is deleted on purpose

Helm's `lookup` function is a simple way to do that:

```yaml
{{- $secret := lookup "v1" "Secret" .Release.Namespace "my-secret" -}}
{{- $password := "" -}}

{{- if $secret -}}
  {{- $password = index $secret.data "password" | b64dec -}}
{{- else -}}
  {{- $password = randAlphaNum 32 -}}
{{- end -}}

apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
stringData:
  password: {{ $password | quote }}
```

This gives you a much safer lifecycle:

1. First install: generate a random 32-character password.
2. Upgrade: read the existing password from the cluster.
3. Normal upgrades do not change credentials.
4. Delete the `Secret` and reinstall: a new password is generated.

For many small applications, this is enough. It is lazy in the good sense: no new component, no operator, no extra dependency.

There are still a few caveats:

- `lookup` needs access to the Kubernetes API during rendering.
- `helm template` and offline rendering will not behave the same way as `helm install` or `helm upgrade`.
- The Helm client or controller must have permission to read the existing `Secret`.
- This keeps the source of truth inside the cluster, which is fine for app-local credentials but less fine for shared or audited secrets.

## When the in-cluster pattern is enough

The `lookup` pattern is a good fit when:

- the secret belongs to one application
- the chart owns the full lifecycle
- you do not need manual review in Git
- rotation is rare and can be handled deliberately

Examples:

- an internal database password
- a first-start admin password stored only inside the cluster
- a Redis password used by one release

Once the same value must be reused across teams, environments, or delivery pipelines, I would stop generating it inside Helm and move the source of truth elsewhere.

## Encrypting secrets in Git with `sops`

If you want Git to stay the source of truth, [`sops`](https://github.com/getsops/sops) is one of the cleanest options.

Instead of committing plaintext secrets, you commit an encrypted file and decrypt it only for authorized users or automation. `sops` works well with `age`, GPG, and cloud KMS backends.

A typical encrypted file still looks like normal YAML:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
stringData:
  password: ENC[AES256_GCM,data:...,type:str]
sops:
  age:
    - recipient: age1...
  lastmodified: "2026-01-15T00:00:00Z"
  version: 3.9.0
```

Why this approach is nice:

- the manifest stays in Git
- reviews still happen in Git
- access to the raw secret is controlled by keys, not only repository access
- it works well in GitOps workflows

The trade-off is simple: you now need key management. That is still much better than storing plaintext credentials in the repository.

## `ksops`: `sops` for Kustomize workflows

If your deployment flow is based on Kustomize, [`ksops`](https://github.com/viaduct-ai/kustomize-sops) is the natural extension.

It lets Kustomize consume `sops`-encrypted files and render regular Kubernetes manifests from them.

A minimal example looks like this:

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
generators:
  - ksops-secret-generator.yaml
```

```yaml
# ksops-secret-generator.yaml
apiVersion: viaduct.ai/v1
kind: ksops
metadata:
  name: my-secret
files:
  - secret.enc.yaml
```

This is useful when:

- you already use Kustomize overlays
- you want encrypted manifests in Git
- you do not want to switch the whole workflow to Helm just for secrets

In short: `sops` solves encrypted files, `ksops` plugs that idea into a Kustomize-based deployment process.

## Using Vault when the source of truth is external

Sometimes the right answer is: *do not store the real secret in Git or in Helm at all.*

That is where Vault becomes interesting.

With Vault, Kubernetes workloads can fetch secrets at runtime, and in some cases they can fetch **dynamic** secrets with a lease and automatic expiration. This is far better than hardcoding one long-lived password into every environment.

Common patterns are:

- Vault Agent Injector writes secrets into the pod
- the CSI driver mounts secrets as files
- an operator syncs selected values into Kubernetes `Secret` objects

Vault is worth the extra moving parts when you need:

- centralized secret management across many clusters
- short-lived credentials
- strong audit requirements
- database or cloud credentials generated on demand

For one small app, Vault is probably overkill. For a platform shared by many teams, it often becomes the cleanest model.

## Which option should you pick?

My practical rule is simple:

| Need | Good default |
| --- | --- |
| One app, one chart, internal password | Helm + `lookup` |
| Git as source of truth, encrypted manifests | `sops` |
| Kustomize-based GitOps | `ksops` + `sops` |
| Shared platform, audit, dynamic credentials | Vault |

Do not start with Vault if all you need is a generated password for one chart.

Do not keep inventing Helm tricks if the secret really belongs to a central security workflow.

## Conclusion

Kubernetes secrets are easy to create, but the important design choice is where the truth lives.

If the value is local to one release, the `lookup` pattern is simple and effective.

If the value must live in Git, encrypt it with `sops`.

If your world is Kustomize, use `ksops`.

If secrets need to be shared, rotated, audited, or generated dynamically, move them to Vault and let Kubernetes consume them instead of owning them.

The simple answer is often the best one: keep secrets as close as possible to the workload, and only add more machinery when the requirements actually demand it.
