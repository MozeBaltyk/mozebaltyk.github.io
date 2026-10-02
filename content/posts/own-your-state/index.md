---
title: ⛄ Own Your Terraform State with an S3-Compatible Backend
description: "Store Terraform or OpenTofu state yourself without relying on Terraform Cloud."
date: 2025-05-05T03:48:10+02:00
noindex: false
featured: true
draft: false
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
  - IaC
  - Storage
authors:
  - mozebaltyk
images:
  - ./carousel/own-your-state.webp
sidebar: false
---

Recently, I was reading an article about
[Terraform Cloud](https://blog.puvvadi.me/posts/getting-started-terraform-cloud/)
and it reminded me of a problem I had already encountered while building my GitHub Actions workflows:

**where should Terraform state live when the CI runners are disposable?**

Terraform Cloud is one possible answer.

But it is not the only one.

If your object-storage provider exposes an S3-compatible API, you can keep control of the state yourself and use it directly as a remote backend.

In my case, I use **DigitalOcean Spaces** together with OpenTofu.

## Why does remote state matter?

By default, Terraform and OpenTofu store their state locally in:

```text
terraform.tfstate
```

That works perfectly on a workstation.

Things become more interesting in CI.

A GitHub Actions runner is temporary. Once the runner disappears, anything stored only on its local filesystem disappears with it.

Consider a workflow such as:

```text
init
  │
  ▼
plan
  │
  ▼
apply
```

If every stage runs in an isolated environment and the state exists only as a local file, the next environment cannot automatically access it.

Uploading `terraform.tfstate` as a CI artifact would technically solve part of the problem, but it is not a great architecture.

Terraform/OpenTofu state can contain:

- Resource IDs
- Infrastructure metadata
- Outputs
- Provider information
- Potentially sensitive values

The state is also something that multiple executions may need to access safely.

That is exactly what **remote backends** are designed for.

## What does the backend do?

A backend defines where Terraform or OpenTofu stores its state.

With an S3 backend, the architecture becomes:

```text
GitHub Actions runner
        │
        │ OpenTofu
        ▼
┌─────────────────────┐
│ S3-compatible API   │
│                     │
│ terraform.tfstate   │
└─────────────────────┘
```

The CI runner itself remains disposable.

The state does not.

This also means that `s3cmd` is not actually responsible for storing Terraform state.

I use `s3cmd` to:

- Connect to the object-storage service
- Create buckets
- Inspect their contents
- Remove temporary buckets when required

OpenTofu itself communicates with the bucket through its **S3 backend**.

## Why DigitalOcean Spaces?

I was already deploying infrastructure on DigitalOcean, and
[DigitalOcean Spaces](https://docs.digitalocean.com/products/spaces/)
provides an S3-compatible object-storage API.

That means tools designed for Amazon S3 can also communicate with Spaces by using the appropriate endpoint and credentials.

Conceptually:

```text
                 ┌──────────────┐
                 │ GitHub       │
                 │ Actions      │
                 └──────┬───────┘
                        │
                        │ tofu init / plan / apply
                        ▼
                 ┌──────────────┐
                 │ OpenTofu     │
                 │ S3 backend   │
                 └──────┬───────┘
                        │
                        │ S3-compatible API
                        ▼
                 ┌──────────────┐
                 │ DigitalOcean │
                 │ Spaces       │
                 └──────────────┘
```

No Terraform Cloud account is required.

## The main steps

The workflow is relatively simple:

1. Configure access to the S3-compatible service
2. Create or provide the backend bucket
3. Configure OpenTofu to use that bucket
4. Run `init`, `plan`, and `apply`
5. Clean up the bucket only if the infrastructure is intentionally ephemeral

The last point is important.

For permanent infrastructure, I would normally keep the state bucket persistent.

For short-lived test environments, dynamically creating and deleting the state bucket can make sense.

## GitHub Actions configuration

First, I expose the required values to the workflow.

```yaml
env:
  DO_PAT: ${{ secrets.DIGITALOCEAN_ACCESS_TOKEN }}

  AWS_ACCESS_KEY_ID: ${{ secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.DIGITALOCEAN_SPACES_SECRET_KEY }}

  REGION: ${{ secrets.DIGITALOCEAN_REGION }}

  MOUNT_POINT: "/opt/rkub"

  BUCKET: "rkub-github-action-${{ github.run_id }}"
```

The important variables for the backend are:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
REGION
BUCKET
```

The credentials are stored as GitHub Actions secrets rather than directly in the workflow.

## Create the bucket

For this project, I used `s3cmd` to create the Space dynamically.

```yaml
steps:
  - name: Set up s3cmd
    uses: s3-actions/s3cmd@main
    with:
      provider: digitalocean
      region: ${{ secrets.DIGITALOCEAN_REGION }}
      access_key: ${{ secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN }}
      secret_key: ${{ secrets.DIGITALOCEAN_SPACES_SECRET_KEY }}

  - name: Create Space bucket
    run: |
      if [[ "${BUCKET}" != "terraform-backend-github" ]]; then
        s3cmd mb "s3://${BUCKET}"
      fi

      sleep 10
```

The bucket exists independently from the runner.

At that point, it can be used as the OpenTofu backend.

## Configure the S3 backend

The Terraform/OpenTofu configuration also needs an S3 backend block.

For example:

```hcl
terraform {
  backend "s3" {
    key = "terraform.tfstate"

    # DigitalOcean Spaces is S3-compatible.
    endpoints = {
      s3 = "https://REGION.digitaloceanspaces.com"
    }

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
  }
}
```

The exact compatibility options depend on the S3-compatible provider and the OpenTofu version being used.

I deliberately leave the bucket name outside the configuration because it is supplied dynamically by the CI workflow.

Then initialization can inject the bucket:

```yaml
- name: Tofu Init
  id: init
  run: |
    cd ./DO/infra

    tofu init \
      -backend-config="bucket=${BUCKET}"
```

OpenTofu now knows where the state belongs.

The backend becomes the persistent part of the workflow.

## Validate, plan and apply

The rest of the pipeline remains fairly conventional.

```yaml
- name: Checkout files
  uses: actions/checkout@v4

- name: Setup Tofu
  uses: opentofu/setup-opentofu@v1
  with:
    tofu_version: "1.7.3"

- name: Tofu Init
  id: init
  run: |
    cd ./DO/infra
    tofu init -backend-config="bucket=${BUCKET}"

- name: Tofu Validate
  id: validate
  run: |
    cd ./DO/infra
    tofu validate -no-color

- name: Tofu Plan
  id: plan
  run: |
    cd ./DO/infra

    tofu plan \
      -out=terraform.tfplan \
      -var "GITHUB_RUN_ID=$GITHUB_RUN_ID" \
      -var "token=${DO_PAT}" \
      -var "worker_count=${WORKER_COUNT}" \
      -var "controller_count=${CONTROLLER_COUNT}" \
      -var "instance_size=${SIZE}" \
      -var "spaces_access_key_id=${{ secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN }}" \
      -var "spaces_access_key_secret=${{ secrets.DIGITALOCEAN_SPACES_SECRET_KEY }}" \
      -var "mount_point=${MOUNT_POINT}" \
      -var "airgap=${AIRGAP}" \
      -var "terraform_backend_bucket_name=${BUCKET}"

  continue-on-error: true

- name: Tofu Plan Status
  if: steps.plan.outcome == 'failure'
  run: exit 1

- name: Tofu Apply
  run: |
    cd ./DO/infra
    tofu apply terraform.tfplan
```

The important part is not the `plan` or `apply` commands themselves.

It is that every OpenTofu command points to the same backend.

```text
          Runner A
          tofu init
              │
              ▼
        ┌───────────┐
        │           │
        │ S3 state  │
        │           │
        └───────────┘
              ▲
              │
          Runner B
          tofu init
```

Different runners can therefore work against the same remote state instead of depending on a local `terraform.tfstate`.

## State locking

Remote storage solves persistence, but there is another problem:

**what happens if two pipelines try to modify the same state at the same time?**

That is where state locking becomes important.

A lock prevents two writers from modifying the same state concurrently.

Modern OpenTofu versions support S3-based locking with:

```hcl
use_lockfile = true
```

For example:

```hcl
terraform {
  backend "s3" {
    bucket       = "terraform-backend"
    key          = "rkub/terraform.tfstate"
    region       = "fra1"
    use_lockfile = true
  }
}
```

Whether native S3 locking works correctly with a particular S3-compatible provider depends on the API features that provider implements, so it is something worth validating before relying on it.

For a simple personal CI environment where only one workflow can run at a time, GitHub Actions concurrency controls can also provide an additional safeguard.

For example:

```yaml
concurrency:
  group: rkub-infrastructure
  cancel-in-progress: false
```

This does not replace backend locking, but it can prevent multiple copies of the same workflow from racing against each other.

## Keep the state bucket outside the managed infrastructure

There is one architectural trap worth mentioning.

Imagine that the infrastructure being destroyed contains the bucket holding its own Terraform state.

That creates an obvious chicken-and-egg problem.

```text
OpenTofu
   │
   ├── manages cluster
   ├── manages network
   └── manages state bucket
             │
             └── contains OpenTofu state
```

Destroying everything may also destroy the information required to manage everything.

For permanent infrastructure, the backend should generally belong to a small administrative layer that exists independently from the environment it manages.

Something closer to:

```text
Administrative infrastructure
        │
        └── State bucket
                │
                ▼
             OpenTofu
                │
                ▼
       Application infrastructure
       ├── network
       ├── cluster
       ├── storage
       └── workloads
```

That separation makes the whole setup much safer.

## What about temporary infrastructure?

My original Rkub workflow had a slightly different requirement.

The entire infrastructure was temporary.

The workflow created an environment, used it, and eventually destroyed it.

In that specific situation, dynamically creating a bucket such as:

```text
rkub-github-action-${GITHUB_RUN_ID}
```

made sense.

The state was only needed for the lifetime of that ephemeral environment.

The lifecycle became:

```text
Create backend bucket
        │
        ▼
   tofu init
        │
        ▼
   tofu apply
        │
        ▼
 Run workload/tests
        │
        ▼
  tofu destroy
        │
        ▼
Delete backend bucket
```

This is different from the normal production case.

For a long-lived environment, I would keep the backend.

For an intentionally disposable environment, the backend can be disposable too.

## Why not Terraform Cloud?

Terraform Cloud provides much more than remote state.

It can provide:

- Remote runs
- State management
- Team collaboration
- Policy controls
- Variable management
- Governance features

Those may be useful depending on the organization.

My requirement here was much smaller.

I needed:

> a reliable place to store state between ephemeral CI runners.

An S3-compatible object-storage service already solved that problem.

I therefore did not need to introduce another platform simply to store the state.

This is less about being against Terraform Cloud and more about choosing the smallest tool that solves the requirement.

## What is `s3cmd` doing here?

This is worth repeating because the original version of this article blurred the distinction.

`s3cmd` is **not the Terraform backend**.

It is an S3 client.

In this workflow I use it to bootstrap and manage the object-storage bucket.

The responsibilities are:

```text
s3cmd
  │
  └── create / inspect / delete bucket

OpenTofu
  │
  └── read / write / lock state

DigitalOcean Spaces
  │
  └── persist objects
```

Once the bucket exists, OpenTofu does not need `s3cmd` to manage its state.

That separation makes the architecture easier to understand.

## The full pipeline

Below is the complete GitHub Actions workflow from the **Rkub** project:

{{< code-snippet github-workflows.yaml yaml >}}

## Conclusion

Terraform and OpenTofu state should not depend on the lifetime of a CI runner.

A remote backend solves that problem by moving state out of the execution environment and into persistent storage.

In this case:

```text
GitHub Actions
      │
      ▼
   OpenTofu
      │
      ▼
 S3 backend
      │
      ▼
DigitalOcean Spaces
```

`s3cmd` is useful around the edges for managing the bucket, but OpenTofu itself is responsible for using that bucket as its backend.

For permanent infrastructure, the backend should generally be persistent and independent from the infrastructure it manages.

For short-lived CI environments such as my Rkub workflow, dynamically creating and deleting the backend can also be a perfectly reasonable design.

The important part is that the **runner remains disposable while the state lives somewhere intentional**.

And if an S3-compatible backend already solves the problem, adding another platform is optional rather than mandatory.