---
date: 2023-08-01T21:00:00+08:00
title: 🐄 RKE2
nav_weight: 65 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Kubernetes
  - IaC
---

## General Checks

Nice gist to troubleshoot etcd [link](https://gist.github.com/superseb/3b78f47989e0dbc1295486c186e944bf#on-the-etcd-host-itself)

```bash
journalctl -u rke2-server.service -f

tail -f /var/lib/rancher/rke2/agent/containerd/containerd.log

tail -f /var/lib/rancher/rke2/agent/logs/kubelet.log

# crictl
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
/var/lib/rancher/rke2/bin/crictl ps

/var/lib/rancher/rke2/bin/crictl --config /var/lib/rancher/rke2/agent/etc/crictl.yaml ps

/var/lib/rancher/rke2/bin/crictl --runtime-endpoint unix:///run/k3s/containerd/containerd.sock ps -a

/var/lib/rancher/rke2/bin/ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io container ls

# Kubectl
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export PATH=$PATH:/usr/local/bin/:/var/lib/rancher/rke2/bin/
kubectl get addon -A
```

## Check etcd endpoint status

```bash
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
etcdcontainer=$(/var/lib/rancher/rke2/bin/crictl ps --label io.kubernetes.container.name=etcd --quiet)
/var/lib/rancher/rke2/bin/crictl exec $etcdcontainer sh -c "ETCDCTL_ENDPOINTS='https://127.0.0.1:2379' ETCDCTL_CACERT='/var/lib/rancher/rke2/server/tls/etcd/server-ca.crt' ETCDCTL_CERT='/var/lib/rancher/rke2/server/tls/etcd/server-client.crt' ETCDCTL_KEY='/var/lib/rancher/rke2/server/tls/etcd/server-client.key' ETCDCTL_API=3 etcdctl endpoint status --cluster --write-out=table"
```

## Check etcd health status

```bash
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
etcdcontainer=$(/var/lib/rancher/rke2/bin/crictl ps --label io.kubernetes.container.name=etcd --quiet)
/var/lib/rancher/rke2/bin/crictl exec $etcdcontainer sh -c "ETCDCTL_ENDPOINTS='https://127.0.0.1:2379' ETCDCTL_CACERT='/var/lib/rancher/rke2/server/tls/etcd/server-ca.crt' ETCDCTL_CERT='/var/lib/rancher/rke2/server/tls/etcd/server-client.crt' ETCDCTL_KEY='/var/lib/rancher/rke2/server/tls/etcd/server-client.key' ETCDCTL_API=3 etcdctl endpoint health --cluster --write-out=table"
```