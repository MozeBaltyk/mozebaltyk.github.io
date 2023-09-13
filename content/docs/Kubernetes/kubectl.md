---
date: 2023-08-01T21:00:00+08:00
title: 🎲 Kubectl
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Admnistration
categories:
  - Kubernetes
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

## Secrets

```bash 
kubectl create secret tls urls-tls --key="tls.key" --cert="tls.crt"  -n longhorn-system --dry-run=client -o yaml
```