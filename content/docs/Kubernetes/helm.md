---
date: 2023-08-01T21:00:00+08:00
title: 🎡 Helm
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Devops
categories:
  - Docs
tags:
  - Kubernetes
  - Admin
---

## Admnistration

* See what is currently installed

```bash
helm list -A
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
nesux3  default         1               2022-08-12 20:01:16.0982324 +0200 CEST  deployed        nexus3-1.0.6    3.37.3
```

* Install/Uninstall
```bash
helm status nesux3
helm uninstall nesux3
helm install nexus3 
helm history nexus3

# work even if already installed
helm upgrade --install ingress-nginx ${DIR}/helm/ingress-nginx \
  --namespace=ingress-nginx \
  --create-namespace \
  -f $helm {DIR}/helm/ingress-values.yml

#Make helm unsee an apps (it does not delete the apps) 
kubectl delete secret -l owner=helm,name=argo-cd
```

* Handle Helm Repo and Charts
```bash
#Handle repo 
helm repo list
helm repo add gitlab https://charts.gitlab.io/
helm repo update

#Pretty usefull to configure
helm show values elastic/eck-operator
helm show values grafana/grafana --version 8.5.1 

#See different version available
helm search repo hashicorp/vault
helm search repo hashicorp/vault -l

# download a chart
helm fetch ingress/ingress-nginx --untar 
```


## Tips 

* List all images needed in helm charts (but not the one with no tags)
```bash
helm template -g longhorn-1.4.1.tgz |yq -N '..|.image? | select(. == "*" and . != null)'|sort|uniq|grep ":"|egrep -v '*:[[:blank:]]' || echo ""
```