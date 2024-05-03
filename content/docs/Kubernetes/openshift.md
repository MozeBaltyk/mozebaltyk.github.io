---
date: 2023-08-01T21:00:00+08:00
title: 🐠 OpenShift
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Infrastructure
categories:
  - Kubernetes
---

## Utils

```bash
# Get Nodes which are Ready
oc get nodes --output jsonpath='{range .items[?(@.status.conditions[-1].type=="Ready")]}{.metadata.name} {.status.conditions[-1].type}{"\n"}{end}'

# get images from all pods in a namespace
oc get pods -n  --output jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}'
```
