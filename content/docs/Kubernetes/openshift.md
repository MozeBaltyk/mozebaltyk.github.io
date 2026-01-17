---
date: 2023-08-01T21:00:00+08:00
title: 🐠 OpenShift
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - Devops
tags:
  - Kubernetes
  - Infrastructure
---
## OC Mirror

* Need at least one Operator:

```yaml
kind: ImageSetConfiguration
apiVersion: mirror.openshift.io/v1alpha2
archiveSize: 4
storageConfig:
  registry:
    imageURL: quay.example.com:8443/mirror/oc-mirror-metadata
    skipTLS: false
mirror:
  platform:
    architectures:
      - "amd64"
    channels:
    - name: stable-4.14
      type: ocp
      shortestPath: true
    graph: true
  operators:
    - catalog: registry.redhat.io/redhat/redhat-operator-index:v4.14
      packages:
        - name: kubevirt-hyperconverged
          channels:
            - name: 'stable'
        - name: serverless-operator
          channels:
            - name: 'stable'
  additionalImages:
  - name: registry.redhat.io/ubi9/ubi:latest
  helm: {}
```

```bash
# install oc-mirror:
curl https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/oc-mirror.rhel9.tar.gz -O

# Get an example of imageset
oc-mirror init --registry quay.example.com:8443/mirror/oc-mirror-metadata

# Find operators in the list of Operators, channels, packages
oc-mirror list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.14
oc-mirror list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.14 --package=kubevirt-hyperconverged
oc-mirror list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.14 --package=kubevirt-hyperconverged --channel=stable

# mirror with a jumphost which online access
oc-mirror --config=imageset-config.yaml docker://quay.example.com:8443

# mirror for airgap
oc-mirror --config=imageSetConfig.yaml file://tmp/download
oc-mirror --from=/tmp/upload/ docker://quay.example.com/ocp/operators

# Refresh OperatorHub 
oc get pod -n openshift-marketplace

# Get the index pod and delete it to refresh 
oc delete pod cs-redhat-operator-index-m2k2n -n openshift-marketplace 
```

## Install

```bash
## Get the coreOS which is gonna to be installed 
openshift-install coreos print-stream-json | grep '\.iso[^.]'

openshift-install create install-config

openshift-install create manifests

openshift-install create ignition-configs

openshift-install create cluster --dir . --log-level=info
openshift-install destroy cluster --log-level=info
```

* for baremetal make a iso boot USB

```bash
dd if=$HOME/ocp-latest/rhcos-live.iso of=/dev/sdb bs=1024k status=progress
```

## Add node 

```bash
export OPENSHIFT_CLUSTER_ID=$(oc get clusterversion -o jsonpath='{.items[].spec.clusterID}')
export CLUSTER_REQUEST=$(jq --null-input --arg openshift_cluster_id "$OPENSHIFT_CLUSTER_ID" '{
  "api_vip_dnsname": "<api_vip>", 
  "openshift_cluster_id": $openshift_cluster_id,
  "name": "<openshift_cluster_name>" 
}')
```

## Platform in install-config

* Get all info on how to config

```shell
openshift-install explain installconfig.platform.libvirt
```

```yaml
## none 
platform:
   none: {}

## baremetal - use ipmi to provision baremetal
platform:
  baremetal:
    apiVIP: 192.168.111.5
    ingressVIP: 192.168.111.7
    provisioningNetwork: "Managed"
    provisioningNetworkCIDR: 172.22.0.0/24
    provisioningNetworkInterface: eno1
    clusterProvisioningIP: 172.22.0.2
    bootstrapProvisioningIP: 172.22.0.3
    hosts:
      - name: master-0
        role: master
        bmc:
          address: ipmi://192.168.111.1
          username: admin
          password: password
        bootMACAddress: 52:54:00:a1:9c:ae
        hardwareProfile: default
      - name: master-1
        role: master
        bmc:
          address: ipmi://192.168.111.2
          username: admin
          password: password
        bootMACAddress: 52:54:00:a1:9c:af
        hardwareProfile: default
      - name: master-2
        role: master
        bmc:
          address: ipmi://192.168.111.3
          username: admin
          password: password
        bootMACAddress: 52:54:00:a1:9c:b0
        hardwareProfile: default

## vpshere - old syntax and deprecated form (new one in 4.15 with "failure domain")
vsphere:
    vcenter:
    username:
    password:
    datacenter:
    defaultDatastore:
    apiVIPs:
    - x.x.x.x
    ingressVIPs:
    - x.x.x.x

## new syntax
platform:
  vsphere:
    apiVIPs:
    - x.x.x.x
    datacenter: xxxxxxxxxxxx_datacenter
    defaultDatastore: /xxxxxxxxxxxx_datacenter/datastore/Shared Storages/ssd-001602
    failureDomains:
     - name: CNV4
      region: fr
      server: xxxxxxxxxxxx.ovh.com
      topology:
        computeCluster: /xxxxxxxxxxxx_datacenter/host/Management Zone Cluster
        datacenter: xxxxxxxxxxxx_datacenter
        datastore: /xxxxxxxxxxxx_datacenter/datastore/Shared Storages/ssd-001602
        networks:
        - vds_mgmt
      zone: dc
    ingressVIPs:
    - x.x.x.x
    password: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    username: admin
    vCenter: xxxxxxxxxxx.ovh.com
    vcenters:
    - datacenters:
      - xxxxxxxxxx_datacenter
      password: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      port: 443
      server: xxxxxxx.ovh.com
      user: admin
```

## Utils

```bash
# Get Cluster ID
oc get clusterversion -o jsonpath='{.items[].spec.clusterID}'

# Get Nodes which are Ready
oc get nodes --output jsonpath='{range .items[?(@.status.conditions[-1].type=="Ready")]}{.metadata.name} {.status.conditions[-1].type}{"\n"}{end}'

# get images from all pods in a namespace
oc get pods -n  --output jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}'
```

## Set OperatorHub

* in airgap

```bash
oc get catalogsources -n openshift-marketplace
```
