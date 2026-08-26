--- 
title: 💫 Secrets in kubernetes
description: "A practical guide about handling secrets in Kubernetes."
date: 2026-08-26T03:48:10+02:00
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
  - ./carousel/secrets-in-kubernetes.webp
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

The most direct approach is to generate a random value inside the chart. 
In Helm, this kind of reusable snippet is usually written as a helper at this place: `templates/_helpers.tpl`.

For example:

```yaml
{{- define "mychart.password" -}}
{{- randAlphaNum 32 | quote -}}
{{- end -}}
```

Then another template in the same chart can call it with `include`:

```yaml
password: {{ include "mychart.password" . }}
```

`mychart.password` is just the helper name. The `.` passes the current chart context into the helper.

The `_helpers.tpl` filename is only a convention, but it is the usual one. Helm will load templates from `templates/`, and files starting with `_` are commonly used for partials/helpers rather than rendered Kubernetes objects.

This works, but it has one big problem: it generates a new random value every time Helm renders the template.

That means a plain `helm upgrade` can rotate credentials even when you did not want rotation at all. For a database password, an admin token, or any value reused by another workload, that is usually the wrong behavior.

This pattern is only acceptable for short-lived or throwaway environments, for example a demo namespace, a preview deployment, or a local dev install that gets reset often. For real credentials such as a database password, an admin password, or an API key, this is usually the wrong pattern.

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

A common small-scale setup is `sops` + `age`: simple keys, simple files, no extra service.

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

### A minimal `sops` workflow

Start by creating an `age` key pair on the machine allowed to decrypt secrets:

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
```

The first command creates the private key file. The second prints the matching **public** key, which starts with `age1...`.

Then add a minimal `.sops.yaml` at the root of the repository:

```yaml
creation_rules:
  - path_regex: .*secret(\.sops)?\.ya?ml$
    encrypted_regex: ^(data|stringData)$
    key_groups:
      - age:
          - age1replace-with-your-public-key
```

This means:

- any file named like `db-secret.yaml`, `db-secret.sops.yaml`, or `secret.yml` matches the rule
- only the `data` and `stringData` fields are encrypted
- the matching private key can decrypt the file later

Now create a normal Kubernetes manifest:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
stringData:
  password: supersecret
```

Save it for example as `db-secret.sops.yaml`, then encrypt it in place:

```bash
sops -e -i db-secret.sops.yaml
```

From there the day-to-day workflow is simple:

```bash
# View decrypted content locally
sops -d db-secret.sops.yaml

# Edit the secret safely
sops db-secret.sops.yaml

# Apply it to the cluster
sops -d db-secret.sops.yaml | kubectl apply -f -
```

That last command is the key idea: Git stores only the encrypted file, while Kubernetes still receives a normal `Secret` manifest.

If you deploy with Helm rather than plain `kubectl`, the same pattern works with an encrypted values file:

```yaml
# values.secret.sops.yaml
db:
  password: supersecret
```

```bash
sops -e -i values.secret.sops.yaml
helm upgrade --install myapp ./chart \
  -f values.yaml \
  -f <(sops -d values.secret.sops.yaml)
```

That process-substitution example works in Bash or Zsh. In CI you can do the same thing with a temporary file if needed.

### How to manage the private keys

The `age1...` values in `.sops.yaml` are **public** keys, so committing them is fine. The sensitive part is the matching private key, usually stored in: `~/.config/sops/age/keys.txt`

For a small team, a practical setup is:
- one private key per person
- one separate private key for CI
- one recovery key kept offline or in a tightly controlled vault

Then `.sops.yaml` includes all the matching public keys as recipients.

Then simple rules are:
- keep your working private key locally on your machine
- back it up in a password manager or secure vault
- never commit it to Git
- do not share one human key between multiple people

It can also be manageable for a small team. 

For example, this is a healthy pattern:
- Alice has her own `age` key pair
- Bob has his own `age` key pair
- CI has its own `age` key pair stored in CI secrets
- a break-glass recovery key is stored in a secure vault

If someone leaves the team, rotate by:

1. adding the new public key to `.sops.yaml`
2. re-encrypting the files
3. removing the old public key

This is another reason `age` is nice: the model is boring and easy to reason about.

### About the larger `.sops.yaml` examples you often see

You will often find a more advanced config like this:

- `keys:` defines reusable recipient lists
- `&name` and `*name` are YAML anchors and aliases, just a DRY way to reuse the same values
- `creation_rules:` says which files match which policy
- `input_type: yaml` or `env` tells `sops` how to parse the file
- `encrypted_regex: ^(data|stringData)$` means only those Kubernetes fields are encrypted
- `stores.yaml.indent: 2` is only output formatting

So the long version is not a different mechanism. It is just the same policy written in a more reusable way for teams with many keys and file types.

Here is an example: 

```yaml
---
# This example uses YAML anchors which allows reuse of multiple keys
# without having to repeat yourself.
# Also see https://github.com/Mic92/dotfiles/blob/master/nixos/.sops.yaml
# for a more complex example.
keys:
  age:
    - &ci_age_key age1wdapsm2nw9pr0nmak892gqwat44uhay7d7z5fqtwgsmm6ecatggsfql3yx
    - &toto_age_key age19zycawkart4t4l7a238w0n2w0rmw6anjadwv9yr3ce3js4dz3dcqqgkvsw
    - &tata_age_key age16krrdc5j8t9pf5qyldhgq59ayjktrkzs6kq730dpu4lpy6gkt9qqd8keur
creation_rules:
  - path_regex: .+secret(\.sops)?\.ya?ml
    input_type: yaml
    encrypted_regex: ^(data|stringData)$
    key_groups:
      - age: &key_groups
          - *ci_age_key
          - *toto_age_key
          - *tata_age_key
  - path_regex: .+secret(\.sops)?\.env
    input_type: env
    key_groups:
      - age: *key_groups
stores:
  yaml:
    indent: 2
```

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

### A minimal `ksops` workflow

First, keep using the same `sops` setup as above. The encrypted file can stay a normal Kubernetes `Secret`, for example `secret.sops.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
stringData:
  password: supersecret
```

Encrypt it:

```bash
sops -e -i secret.sops.yaml
```

Then wire it into Kustomize:

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
  - secret.sops.yaml
```

Build and apply it with:

```bash
kustomize build --enable-alpha-plugins --enable-exec . | kubectl apply -f -
```

The important caveat is that `ksops` is a Kustomize plugin. So you usually render with `kustomize build` rather than plain `kubectl apply -k`.

In a GitOps setup, the same idea applies, but the controller needs a plugin or sidecar able to run `ksops` during render time.

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

### A minimal Vault workflow

Vault is usually not bootstrapped by every application team from scratch. In practice the platform team configures Vault and Kubernetes authentication once, then applications consume it.

From an application point of view, the workflow is roughly:

1. Store the secret in Vault.
2. Bind a Vault role to the Kubernetes service account.
3. Annotate the pod so Vault injects the secret at runtime.

For example, write a secret to Vault:

```bash
vault kv put kv/myapp password="supersecret"
```

If you want Vault to generate the password for you instead of typing one yourself, use Vault's random endpoint and store the result:

```bash
vault kv put kv/myapp \
  password="$(vault write -field=random_bytes sys/tools/random/24 format=base64)"
```

That is a nice middle ground:

- Vault generates the random value
- Vault stores it in KV
- the pod still reads it through Vault Agent injection

If the backend supports dynamic credentials, go one step further and let Vault generate them on demand through a secrets engine instead of storing one long-lived password at all.

Then create a policy and role. Assuming Kubernetes auth is already configured in Vault, the role can be bound to one service account:

```hcl
# myapp-policy.hcl
path "kv/data/myapp" {
  capabilities = ["read"]
}
```

```bash
vault policy write myapp myapp-policy.hcl

vault write auth/kubernetes/role/myapp \
  bound_service_account_names=myapp \
  bound_service_account_namespaces=default \
  policies=myapp \
  ttl=24h
```

Then annotate the workload:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "myapp"
        vault.hashicorp.com/agent-inject-secret-config.txt: "kv/data/myapp"
        vault.hashicorp.com/agent-inject-template-config.txt: |
          {{`{{- with secret "kv/data/myapp" -}}`}}
          export PASSWORD="{{`{{ .Data.data.password }}`}}"
          {{`{{- end -}}`}}
    spec:
      serviceAccountName: myapp
      containers:
        - name: myapp
          image: nginx:stable
```

When the pod starts, Vault Agent injects a file containing the rendered secret. The application reads that file instead of reading from a Kubernetes `Secret` object.

This is the big difference from `sops`: with Vault, the secret can stay outside Git and even outside Kubernetes until the pod starts.

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
