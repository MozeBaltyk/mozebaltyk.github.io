---
date: 2023-08-01T21:00:00+08:00
title: 🔱 K3S
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - Devops
tags:
  - Kubernetes
  - Infrastructure
---


* Specific to RHEL

```bash
# Create a trust zone for the two interconnect
sudo firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16 #pods
sudo firewall-cmd --permanent --zone=trusted --add-source=10.43.0.0/16 #services 
sudo firewall-cmd --reload
sudo firewall-cmd --list-all-zones

# on Master
sudo rm -f /var/lib/cni/networks/cbr0/lock
sudo /usr/local/bin/k3s-killall.sh
sudo systemctl restart k3s
sudo systemctl status k3s

# on Worker
sudo rm -f /var/lib/cni/networks/cbr0/lock
sudo /usr/local/bin/k3s-killall.sh
sudo systemctl restart k3s-agent
sudo systemctl status k3s-agent
```

## Check Certificates

```bash
# Get CA from K3s master
openssl s_client -connect localhost:6443 -showcerts < /dev/null 2>&1 | openssl x509 -noout -enddate
openssl s_client -showcerts -connect 193.168.51.103:6443 < /dev/null 2>/dev/null|openssl x509 -outform PEM
openssl s_client -showcerts -connect 193.168.51.103:6443 < /dev/null 2>/dev/null|openssl x509 -outform PEM | base64 | tr -d '\n'

# Check end date:
for i in `ls /var/lib/rancher/k3s/server/tls/*.crt`; do echo $i; openssl x509 -enddate -noout -in $i; done

# More efficient: 
cd /var/lib/rancher/k3s/server/tls/
for crt in *.crt; do printf '%s: %s\n' "$(date --date="$(openssl x509 -enddate -noout -in "$crt"|cut -d= -f 2)" --iso-8601)" "$crt"; done | sort

# Check CA issuer
for i in $(find . -maxdepth 1 -type f -name "*.crt"); do  openssl x509 -in ${i} -noout -issuer; done
```

## General Checks RKE2/K3S

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

* check etcd endpoint status

```bash
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
etcdcontainer=$(/var/lib/rancher/rke2/bin/crictl ps --label io.kubernetes.container.name=etcd --quiet)
/var/lib/rancher/rke2/bin/crictl exec $etcdcontainer sh -c "ETCDCTL_ENDPOINTS='https://127.0.0.1:2379' ETCDCTL_CACERT='/var/lib/rancher/rke2/server/tls/etcd/server-ca.crt' ETCDCTL_CERT='/var/lib/rancher/rke2/server/tls/etcd/server-client.crt' ETCDCTL_KEY='/var/lib/rancher/rke2/server/tls/etcd/server-client.key' ETCDCTL_API=3 etcdctl endpoint status --cluster --write-out=table"
```

* check etcd health status

```bash
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
etcdcontainer=$(/var/lib/rancher/rke2/bin/crictl ps --label io.kubernetes.container.name=etcd --quiet)
/var/lib/rancher/rke2/bin/crictl exec $etcdcontainer sh -c "ETCDCTL_ENDPOINTS='https://127.0.0.1:2379' ETCDCTL_CACERT='/var/lib/rancher/rke2/server/tls/etcd/server-ca.crt' ETCDCTL_CERT='/var/lib/rancher/rke2/server/tls/etcd/server-client.crt' ETCDCTL_KEY='/var/lib/rancher/rke2/server/tls/etcd/server-client.key' ETCDCTL_API=3 etcdctl endpoint health --cluster --write-out=table"
```

## Rancher

```bash
# Rancher local install - for example on WSL 
sudo podman run --privileged -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher
sudo podman ps 
sudo podman logs 74533d50d991  2>&1 | grep "Bootstrap Password:"
```
<<<<<<< HEAD
=======

## Check Certificates 

```bash
# Get CA from K3s master
openssl s_client -connect localhost:6443 -showcerts < /dev/null 2>&1 | openssl x509 -noout -enddate
openssl s_client -showcerts -connect 193.168.51.103:6443 < /dev/null 2>/dev/null|openssl x509 -outform PEM
openssl s_client -showcerts -connect 193.168.51.103:6443 < /dev/null 2>/dev/null|openssl x509 -outform PEM | base64 | tr -d '\n'

# Check end date:
for i in `ls /var/lib/rancher/k3s/server/tls/*.crt`; do echo $i; openssl x509 -enddate -noout -in $i; done

# More efficient: 
cd /var/lib/rancher/k3s/server/tls/
for crt in *.crt; do printf '%s: %s\n' "$(date --date="$(openssl x509 -enddate -noout -in "$crt"|cut -d= -f 2)" --iso-8601)" "$crt"; done | sort

# Check CA issuer
for i in $(find . -maxdepth 1 -type f -name "*.crt"); do  openssl x509 -in ${i} -noout -issuer; done
```
>>>>>>> ef1214ec03ba0c42d44b7726b9081bb9aa63b5ba
