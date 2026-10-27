---
title: 🚀 A journey to my homelab. - Part 3
description: "What to run on a three-node homelab..."
date: 2026-10-20T03:48:10+02:00
noindex: false
featured: true
draft: true
comment: true
toc: true
reward: true
pinned: false
series:
  - Homelab Journey
categories:
  - Reflection
tags:
  - Homelab
authors:
  - mozebaltyk
images:
  - carousel/homelab-part3.webp
sidebar: false
---

## What would I install on it...

OKD is the interesting part of this project, but it is not the reason for it. The reason is a handful of services I already run, scattered across a NAS, a laptop and a few containers I restart by hand — plus somewhere to try things without breaking the house. The hardware comes from [Part 1](../homelab-project/) and the network from [Part 2](../homelab-project-part-2/); this part is about what actually lands on the cluster.

That gives me a filter for every candidate: does it replace something I currently run badly, and can I back it up? Anything that fails both questions is a demo, and demos belong in a namespace I can delete.

Before listing anything, it is worth separating what the platform brings from what I still have to add. This is the real difference between OKD and k3s, and it is the reason the list below stays short:

| Need | Comes with OKD | Still to add |
|---|---|---|
| Web console, API, authentication | yes | an identity provider instead of `kubeadmin` |
| Metrics and alerting | Prometheus, Alertmanager, Thanos | longer retention, if I ever care |
| Logs | no | the logging operator, or nothing until it hurts |
| Container registry | internal registry, ImageStreams | nothing |
| Ingress | Routes on the HAProxy router | the wildcard certificate from part 2 |
| Certificates | internal CAs only | cert-manager with Let's Encrypt DNS-01 |
| Storage | no default StorageClass | something local, or NFS |
| LoadBalancer services | no | MetalLB, if anything actually needs one |
| GitOps | no | ArgoCD |
| Backups | etcd snapshots | application backups |
| Upgrades | ClusterVersionOperator and the MCO | nothing |

Two rows sold me on OKD. The internal registry means images I build on the cluster can be pushed and pulled without a second registry to maintain, and ImageStreams give me something k3s has no answer for: the cluster records which image a Deployment actually ran, not only which tag it asked for. The upgrade row is the other one — the Machine Config Operator drains and reboots one node at a time, and the ClusterVersionOperator refuses to move on while an operator is degraded. On k3s, upgrading is a script I wrote and will eventually forget.

Everything else is mine to install, and the order matters more than the list: a StorageClass first, because nothing else works without one; cert-manager second, because every Route I expose wants a certificate; ArgoCD third, because from that point on nothing should be applied by hand; MetalLB and the logging operator only if something actually needs them.

Then comes the part I care about. In rough order of how much I would miss them: Forgejo for the repositories this blog and the cluster configuration live in, Immich for photos, Jellyfin and the *arr stack for media, Paperless-ngx for anything that still arrives on paper, Home Assistant for the house, and Uptime Kuma for noticing when one of the others has quietly died.

They are not equally comfortable on OKD, and that is the honest part:

- **Jellyfin** wants QuickSync for transcoding, which means passing `/dev/dri` into the pod: a `hostPath` volume and an SCC that allows it, or the Intel GPU device driver if I want to do it properly.
- **Home Assistant** wants host networking for mDNS discovery, which is another SCC decision rather than a manifest field.
- **Immich** and the *arr containers are ordinary workloads with a PVC and a Route, which is the case OKD handles best.
- **Forgejo** is the one I would fight for, because it hosts the configuration of the cluster that hosts it. That dependency loop is worth naming: if the cluster is down, the repository is down, and the fix is on the laptop.

Two constraints decide the rest of the list.

The first is memory. On three nodes with 32 GB each, the control plane, the monitoring stack and the registry take somewhere between a third and half of the total before the first application starts. That rules out the heavy platform add-ons far more effectively than any argument about whether they are good.

The second is the operator catalog. OKD ships the community catalogs, not Red Hat's, so an operator that exists on OpenShift may simply not be installable here. It is a five-minute check that saves a weekend of designing around something unavailable.

Which is why the "would not install" list is longer than the "would" list: OpenShift Data Foundation, because it wants raw disks and a footprint I do not have; Harbor, because the internal registry already does the job; a service mesh, because three nodes do not have a mesh problem; OpenShift Virtualization, because I want containers, not a hypervisor to patch; and Argo Workflows or Tekton, because a CI system needs more maintenance than the things it builds.

Some of these will move to the other column eventually. That is fine. The point of writing the list down is to notice when the reason changes.

## Categorie and Structure

Every homelab repository I read before starting had already answered this question, and no two answered it the same way.

[Khue's homelab](https://homelab.khuedoan.com/) splits it into `platform/` (ArgoCD, cert-manager, ingress, storage, logging), `external/` (Gitea, Dex, Grafana, Woodpecker), `system/` (the applications he uses) and `apps/` (the Terraform that creates their namespaces). [onedr0p's home-ops](https://github.com/onedr0p/home-ops) splits it into `bootstrap/`, `kubernetes/` and `talos/`, and inside `kubernetes/` there is one directory per namespace, one per application, plus a `components/` directory of reusable Kustomize pieces.

What they agree on is the important part: a hard line between what the cluster needs and what runs on it. What they disagree on is where shared services sit and what counts as an application. Khue's `system/` is what I would call `apps/`, and his `external/` exists because his Gitea has to survive the cluster it configures — the same loop I just described for Forgejo.

For my own cluster, four categories seem to cover everything:

| Category | What belongs | Why it is separate | Examples |
|---|---|---|---|
| Platform | what the cluster needs to function | if it breaks, everything breaks; restored first, upgraded first | ArgoCD, cert-manager, MetalLB, storage, ingress configuration |
| System | shared services applications consume but do not own | one instance serves many applications; losing it degrades everything quietly | logging, secrets, DNS, backup, alert routing |
| Apps | the things I use | independent of each other; a failure is visible and local | Forgejo, Immich, Jellyfin |
| Sandbox | experiments | disposable, no backup, quota-capped | whatever I am trying this week |

These are not folders with nicer names. They are a deployment order. ArgoCD applies them in waves — platform, then system, then apps — because an application that starts before its StorageClass exists does not fail politely: it crash-loops, and the only signal is a wall of red in a UI that does not explain why. Grouping by dependency is what makes the sync order a property of the repository instead of a list of `dependsOn` entries I maintain by hand.

Once the categories exist, the layout is almost forced: one directory per category, one per namespace, one per application.

```text
homelab/
├── bootstrap/              # applied by hand, once
│   └── argocd/
├── platform/
│   ├── cert-manager/
│   ├── metallb/
│   └── storage/
├── system/
│   ├── logging/
│   └── external-secrets/
├── apps/
│   ├── forgejo/
│   └── immich/
└── sandbox/
```

I considered three other layouts and rejected two of them for reasons that would not survive a second person joining:

- **Two repositories, infrastructure and applications.** The usual argument is access control: applications can be changed without cluster-admin. With one committer that buys nothing, and it costs a second pull request for every change that spans both.
- **One repository per application.** Pleasant at forty applications, absurd at four, and it multiplies the ArgoCD wiring by the number of repositories.
- **One flat directory.** Works until the third application needs the same namespace, and then the category has to be invented retroactively.

A single repository with four top-level directories is the smallest thing that keeps the categories visible.

Categories are for humans and for ArgoCD; namespaces are for the API server, and they are not the same thing. `system` is four namespaces, and `apps` is one namespace per application. A label — `homelab.io/category: platform` — is what lets `kubectl get ns -l homelab.io/category=system` answer the question the directories answer in git, even after a folder moves.

One directory escapes GitOps: the one that installs the GitOps controller. Something has to apply ArgoCD before ArgoCD can apply anything, and both repositories above solve it the same way — onedr0p keeps `bootstrap/` with Helmfile and Kustomize, Khue keeps a `bootstrap.yml` inside `platform/argocd/`. I would keep it separate and treat it as the only directory in the repository ever applied by hand, because the alternative is a chicken-and-egg problem documented in a blog post instead of in the repository.

None of this is settled. The layout is a hypothesis about which things change together, and the first time two applications need the same helper, a `components/` directory will appear in it. That is the same lesson as the network: the structure is a snapshot of what I understand today, not a target.

## Roadmap

A homelab roadmap has no deadline, so the only honest way to order it is by risk. The decisions that are expensive to reverse come first, while the cluster is still empty enough to wipe without losing anything.

| Phase | What happens | Done when |
|---|---|---|
| 0 | Network prerequisites | DNS records, DHCP reservations and HAProxy passthrough are in place (part 2) |
| 1 | Install the cluster | agent-based installer or UPI with ignition; three nodes Ready |
| 2 | GitOps before anything else | ArgoCD, the repository skeleton, one trivial application |
| 3 | Platform basics | StorageClass, cert-manager and the wildcard, MetalLB if needed, a backup target |
| 4 | Shared services | logging, external secrets, retention, alert routing |
| 5 | First real workload | one application I use daily, serving from a Route |
| 6 | Deliberately deferred | 2.5 GbE, VLANs, a CARP pair, GPU passthrough, a second cluster |

The order is the commitment; the dates are not. A roadmap with dates on a homelab is fiction — the work happens in evenings, and the estimate is always "two weekends" regardless of the task. What I can commit to is that phase 3 does not start before phase 2 is boring.

Four of those choices deserve their reasoning.

**Identity before anything else.** `kubeadmin` is a shared password with no owner. Every hour it exists is an hour of building habits around it, and every automation that reads a kubeconfig in that window is a thing to redo later. Replacing it on day one costs twenty minutes.

**GitOps before the platform.** If the platform is installed by hand before ArgoCD exists, the order of installation lives in my shell history. Doing it in the other order means every later step is a commit, and the cluster can be rebuilt by pointing ArgoCD at the repository.

**Storage early.** Changing a StorageClass after the fact means moving every PVC that was created against the old one. Doing it while there are none is free, and it is the single most annoying mistake to correct.

**One workload before ten.** The first real application finds the SCC, storage and ingress problems that the next nine would each rediscover. Better to spend a week on one than an evening on each.

Each phase also needs an exit that is not "try harder". If storage turns into a weekend of tuning, NFS and move on. If MetalLB argues with the network, a NodePort and a note. If the installer refuses to converge, wipe and restart from phase 1 with one variable changed. The cluster is disposable until phase 5, and that is exactly what makes phases 1 to 4 cheap to get wrong.

## Installing the Cluster

Phase 1 is the one step that cannot be a commit: it happens before the cluster exists, on machines that do not yet have an operating system.

I am writing a small tool for that seam, [Okub](https://github.com/mozebaltyk/Okub). It is unfinished and has never run against real hardware, so this is a note about intent rather than a recommendation. The plan is to use it in two places, in this order:

- **Preflight.** Before touching a machine, check that the prerequisites part 2 built are actually there: forward and reverse records for `api`, `api-int`, `apps` and the hosts, the VIPs, the credentials, and the host minimums. That check is worth having even if nothing else in the tool ever is.
- **Boot artifacts.** Generate the Agent ISO, or the PXE kernel and initramfs set, along with the boot configuration to hand to pfSense, instead of assembling them by hand every time.

Everything around those two steps — configuration validation, rendering, install monitoring — is scaffolding, and none of it is battle-tested. If it does not survive the first real install, the fallback is the documented path: `openshift-install` by hand, and the tool earns its place later or does not.

## Sources

None of the thinking above is original. These are the repositories I read to see how other people solved the same problems, and the documentation I keep open while doing it. They solve different problems with different hardware, so the value is in the structure rather than in the manifests.

### Code Inspiration
* [Khue's Homelab](https://homelab.khuedoan.com/)
* [Khue's Cloudlab](https://github.com/khuedoan/cloudlab)
* [OneDrop](https://github.com/onedr0p/home-ops)
* [rpi4cluster](https://rpi4cluster.com/)
* [Picluster](https://picluster.ricsanfre.com/docs/home/)
* [Angelnu](https://github.com/angelnu/k8s-gitops)
* [Amrut](https://github.com/amrut-asm/homelab)
* [sawa2d2](https://github.com/sawa2d2/k8s-on-kvm)
* [hivenetes/bootstrapper](https://github.com/hivenetes/k8s-bootstrapper/)
* [Talos homelab](https://github.com/prateekjaindev/homelab)

### Documentation
* [OKD installation overview](https://docs.okd.io/latest/installing/overview/index.html)
* [Installing a cluster on any platform](https://docs.okd.io/latest/installing/installing_platform_agnostic/installing-platform-agnostic.html)
* [Machine configuration](https://docs.okd.io/latest/machine_configuration/index.html)
* [Understanding the Operator Lifecycle Manager](https://docs.okd.io/latest/operators/understanding/olm/olm-understanding-olm.html)
* [Storage](https://docs.okd.io/latest/storage/index.html)
* [Internal registry](https://docs.okd.io/latest/registry/index.html)

### Hardware
* [Jakub Homelab](https://www.linkedin.com/pulse/building-multi-node-homelab-economy-jakub-hovorka-trepe/)
* [Raspberry Pi 5 pricing](https://www.raspberrypi.com/products/raspberry-pi-5/)
* [Used HP EliteDesk 800 Mini G4 prices](https://www.hardwarehoard.com/prices/hp-elitedesk-800-g4-mini)
* [Used HP EliteDesk 800 Mini G6 prices](https://www.hardwarehoard.com/prices/hp-elitedesk-800-g6-mini)
* [500 GB NVMe price tracker](https://rampricehistory.com/ssd/us/500gb-nvme)
