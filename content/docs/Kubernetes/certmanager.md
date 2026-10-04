---
date: 2023-08-01T21:00:00+08:00
title: 📜 CertManager
nav_weight: 30 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Kubernetes
  - Security
---

## What is Cert-Manager

[cert-manager](https://cert-manager.io/) automates the management of X.509
certificates inside Kubernetes via CRDs — it requests, issues, renews and
rotates certificates automatically.

## Key concepts

- **Issuer** — a namespaced certificate signer.
- **ClusterIssuer** — a cluster-wide signer.
- **Certificate** — asks cert-manager to obtain a cert for a name.

Supported backends: ACME (Let's Encrypt), self-signed, CA, Vault, Venafi, …

## Install (helm)

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true
```

## Example: self-signed issuer

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned
spec:
  selfSigned: {}
```

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-tls
spec:
  secretName: example-tls
  dnsNames:
    - example.com
  issuerRef:
    name: selfsigned
    kind: ClusterIssuer
```

## Useful commands

```bash
kubectl get certificate -A
kubectl get certificaterequest -A
kubectl describe certificate <name> -n <ns>

# manual renewal (normally automatic)
cmctl renew <name> -n <ns>
```

## Ops notes

- Cert-Manager stores the TLS key/cert in a `<name>` secret, ready for Ingress.
- `kubectl get challenges` is the first place to look for ACME/Let's Encrypt
  failures.