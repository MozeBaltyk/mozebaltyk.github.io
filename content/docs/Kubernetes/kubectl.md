---
date: 2023-08-01T21:00:00+08:00
title: 🎲 Kubectl
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - Devops
tags:
  - Kubernetes
  - Admin
---

## Connexion to k8s cluster

### Kubeconfig 

* Define KUBECONFIG in your profile

```bash
# Default one 
KUBECONFIG=~/.kube/config

# Several context - to keep splited 
KUBECONFIG=~/.kube/k3sup-lab:~/.kube/k3s-dev

# Or can be specified in command
kubectl get pods --kubeconfig=admin-kube-config
```

* View and Set

```bash
kubectl config view
kubectl config current-context

kubectl config set-context \
dev-context \
--namespace=dev-namespace \
--cluster=docker-desktop \
--user=dev-user

kubectl config use-context lab
```

* Switch context

```bash
#set Namespace 
kubectl config set-context --current --namespace=nexus3
kubectl config get-contexts
```

#### Kubecm

The problem with the kubeconfig is that it get nexted in one kubeconfig and difficult to manage on long term.
The best way to install it, is with Arkade `arkade get kubecm` - see [arkade](https://github.com/alexellis/arkade).

Here, the most usefull
```bash 
kubecm list 
kubecm add -f new-cluster.yaml
kubecm delete
kubecm rename
kubecm switch # Kubecm s (is also fine)
kubecm export
```

## Manage Secrets

* Add Certificates in a Secrets

```bash 
kubectl create secret tls urls-tls --key="tls.key" --cert="tls.crt"  -n longhorn-system --dry-run=client -o yaml
```

