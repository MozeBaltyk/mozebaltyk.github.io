---
date: 2023-08-01T21:00:00+08:00
title: 🐙 Network troubleshooting
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Devops
categories:
  - Docs
tags:
  - Kubernetes
  - Networks
  - Infrastructure
---

## Troubleshoot DNS

* `vi dns.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dnsutils
  namespace: default
spec:
  containers:
  - name: dnsutils
    image: registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3
    command:
      - sleep
      - "infinity"
    imagePullPolicy: IfNotPresent
  restartPolicy: Always
```

* deploy dnsutils 

```bash
k apply -f dns.yml
pod/dnsutils created

kubectl get pods dnsutils
NAME       READY   STATUS    RESTARTS   AGE
dnsutils   1/1     Running   0          36s
```

* Troubleshoot with dnsutils

```bash
kubectl exec -i -t dnsutils -- nslookup kubernetes.default
;; connection timed out; no servers could be reached
command terminated with exit code 1

kubectl exec -ti dnsutils -- cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local psflab.local
nameserver 10.43.0.10
options ndots:5

kubectl get endpoints kube-dns --namespace=kube-system
NAME       ENDPOINTS                                  AGE
kube-dns   10.42.0.6:53,10.42.0.6:53,10.42.0.6:9153   5d1h

kubectl get svc kube-dns --namespace=kube-system
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.43.0.10   <none>        53/UDP,53/TCP,9153/TCP   5d1h
```

## CURL

```bash
cat << EOF > curl.yml 
apiVersion: v1
kind: Pod
metadata:
  name: curl
  namespace: default
spec:
  containers:
  - name: curl
    image: curlimages/curl
    command:
      - sleep
      - "infinity"
    imagePullPolicy: IfNotPresent
  restartPolicy: Always
EOF

k apply -f curl.yml 
 
#Test du DNS
kubectl exec -i -t curl -- curl -v telnet://10.43.0.10:53
kubectl exec -i -t curl -- curl -v telnet://kube-dns.kube-system.svc.cluster.local:53
kubectl exec -i -t curl -- nslookup kube-dns.kube-system.svc.cluster.local

curl -k -I --resolve subdomain.domain.com:52.165.230.62 https:/subdomain.domain.com/
```
