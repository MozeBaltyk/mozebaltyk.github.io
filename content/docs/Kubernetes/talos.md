---
date: 2023-08-01T21:00:00+08:00
title: 🦾 Talos
nav_weight: 60 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Kubernetes
  - IaC
  - Homelab
---

Talos Linux is a minimal, immutable operating system built only for Kubernetes.
It has no SSH server, interactive shell, or package manager. Nodes are configured
declaratively and managed through the authenticated Talos API with `talosctl`.

{{< bs/alert info >}}
Examples use three control-plane nodes and private addresses. Replace every node
name, interface, disk, subnet, and address with values from your environment.
Keep the `talosctl` version aligned with the Talos version you deploy.
{{< /bs/alert >}}

## Why Talos?

K3s or RKE2 on Ubuntu is familiar and flexible, but it leaves two platforms to
operate: the Linux servers and Kubernetes. That includes SSH access, users,
packages, repositories, systemd services, patching, hardening, and configuration
drift.

Talos narrows the node to one purpose:

| Ubuntu with K3s/RKE2 | Talos Linux |
| --- | --- |
| SSH and shell administration | Certificate-authenticated API |
| Mutable packages and files | Immutable, image-based OS |
| Ansible/cloud-init configures the host | Declarative machine configuration |
| Package-by-package updates | Atomic image upgrades and rollback |
| General-purpose troubleshooting tools | `talosctl` resources, logs, and diagnostics |

This reduces the node attack surface and configuration drift. It does **not**
replace Kubernetes RBAC, admission policies, NetworkPolicy, secrets management,
backups, monitoring, or workload security.

Talos is a good fit when nodes run only Kubernetes, supported hardware is used,
and replacement is preferred over manual repair. A general-purpose distribution
may remain simpler for unusual drivers, host-installed vendor agents, or software
that expects systemd and a conventional filesystem.

## Homelab Architecture

### Hardware and Cluster Requirements

A practical highly available homelab uses three similar x86-64 mini PCs, each
connected by wired Ethernet. All three can run the control plane, etcd, and
workloads.

Before installation:

- enable UEFI boot and hardware virtualization;
- create DHCP reservations for all node MAC addresses;
- reserve one unused address for the Kubernetes API virtual IP (VIP);
- exclude the VIP and any LoadBalancer range from the DHCP pool;
- install compatible `talosctl` and `kubectl` versions on the workstation;
- identify every target disk and network interface from Talos maintenance mode.

Example address plan:

| Name | Address | Role |
| --- | --- | --- |
| `node-1` | `192.168.1.111` | Control plane, etcd, workloads |
| `node-2` | `192.168.1.112` | Control plane, etcd, workloads |
| `node-3` | `192.168.1.113` | Control plane, etcd, workloads |
| Kubernetes API VIP | `192.168.1.200` | Stable API endpoint |
| Internal Gateway | `192.168.1.201` | Optional Cilium LoadBalancer IP |

### Three-Node High Availability

Three etcd members provide quorum while one member is unavailable. The API VIP
moves to a healthy control-plane node, so `kubectl` does not depend on one
machine. `talosctl`, however, normally targets the individual node addresses.

{{< bs/alert warning >}}
Three members tolerate one failure, not two. Never bootstrap more than once, and
do not shut down a second control-plane node until the first has fully recovered.
{{< /bs/alert >}}

### Networking, API VIP, and etcd Quorum

Keep these paths distinct:

- `talosctl` → each node on TCP `50000`;
- `kubectl` → API VIP on TCP `6443`;
- etcd → three members, requiring two for quorum;
- applications → Cilium Gateway or LoadBalancer addresses, if configured.

The API VIP must be on the same layer-2 network as the control-plane interfaces.
For routed or cloud environments, use a supported load balancer instead.

## Deploying Kubernetes with Talos

### Installing Talos Linux

Boot each machine from the Talos metal ISO or USB image. In maintenance mode,
record the node address, wired interface, and installation disk:

```bash
export NODE1=192.168.1.111
export NODE2=192.168.1.112
export NODE3=192.168.1.113
export VIP=192.168.1.200

for node in "$NODE1" "$NODE2" "$NODE3"; do
  talosctl --nodes "$node" get links --insecure
  talosctl --nodes "$node" get disks --insecure
done
```

{{< bs/alert warning >}}
Applying an installation configuration writes to the selected disk. Identify it
by model and capacity; do not assume that `/dev/sda` is correct.
{{< /bs/alert >}}

### Generating Machine Configurations

Generate one cluster configuration locally and protect the generated credentials:

```bash
umask 077
mkdir -p talos/patches talos/generated/nodes

talosctl gen config homelab "https://${VIP}:6443" \
  --output-dir talos/generated
```

Create one patch per node. Change the disk, interface, and hostname:

```yaml
machine:
  install:
    disk: /dev/nvme0n1
  network:
    interfaces:
      - interface: enp1s0
        dhcp: true
        vip:
          ip: 192.168.1.200
---
apiVersion: v1alpha1
kind: HostnameConfig
hostname: node-1
auto: off
```

Patch and validate each machine configuration before applying it:

```bash
for node in node-1 node-2 node-3; do
  talosctl machineconfig patch talos/generated/controlplane.yaml \
    --patch "@talos/patches/${node}.yaml" \
    --output "talos/generated/nodes/${node}.yaml" || break
  talosctl validate \
    --config "talos/generated/nodes/${node}.yaml" \
    --mode metal || break
done
```

Do not commit `controlplane.yaml`, `worker.yaml`, `talosconfig`, `kubeconfig`, or
rendered node configurations. They contain cluster credentials.

Apply each configuration while its node is still in maintenance mode:

```bash
talosctl apply-config --insecure --nodes "$NODE1" \
  --file talos/generated/nodes/node-1.yaml
talosctl apply-config --insecure --nodes "$NODE2" \
  --file talos/generated/nodes/node-2.yaml
talosctl apply-config --insecure --nodes "$NODE3" \
  --file talos/generated/nodes/node-3.yaml
```

Remove the installation media and boot from the internal disks.

### Bootstrapping the Kubernetes Cluster

Configure several Talos API endpoints, then bootstrap **one node once**:

```bash
export TALOSCONFIG="$PWD/talos/generated/talosconfig"

talosctl config endpoint "$NODE1" "$NODE2" "$NODE3"
talosctl config node "$NODE1"
talosctl version

talosctl bootstrap --nodes "$NODE1"
talosctl health
```

Export the Kubernetes client configuration and inspect the cluster:

```bash
talosctl kubeconfig ./talos/generated/kubeconfig --nodes "$NODE1"
export KUBECONFIG="$PWD/talos/generated/kubeconfig"

kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods --all-namespaces
```

For a small lab where control-plane nodes also run applications, apply this
machine patch and include it whenever configurations are regenerated:

```yaml
cluster:
  allowSchedulingOnControlPlanes: true
```

```bash
talosctl --nodes "$NODE1,$NODE2,$NODE3" patch machineconfig \
  --patch @talos/patches/allow-workloads.yaml
```

### Validating Cluster Health and Failover

Check Talos, Kubernetes, etcd, DNS, and workload scheduling:

```bash
talosctl health
talosctl --nodes "$NODE1" etcd members
kubectl get nodes -o wide
kubectl get pods --all-namespaces

kubectl create deployment web-test --image=nginx --replicas=3
kubectl rollout status deployment/web-test
kubectl expose deployment web-test --port=80
kubectl run curl-test --rm -it --restart=Never --image=curlimages/curl \
  -- curl --fail http://web-test
kubectl delete service web-test
kubectl delete deployment web-test
```

To test high availability, begin with all nodes healthy and stop only one:

```bash
talosctl health
talosctl --nodes "$NODE1" shutdown
kubectl get nodes
kubectl cluster-info
```

The API VIP should remain available through either surviving node. Power the
stopped node back on, wait until all three nodes are `Ready`, and run
`talosctl health` again before any further failure test.

## Talos Debug

Start from the management layer that is still available. The Talos API is
separate from the Kubernetes API, so it can often diagnose a failed control
plane even when `kubectl` no longer works.

```bash
# Overview
talosctl --nodes "$NODE1" dashboard
talosctl health
talosctl --nodes "$NODE1" service

# Service and kernel logs
talosctl --nodes "$NODE1" service kubelet
talosctl --nodes "$NODE1" logs kubelet --tail 100
talosctl --nodes "$NODE1" dmesg

# Talos resources
talosctl --nodes "$NODE1" get links
talosctl --nodes "$NODE1" get addresses
talosctl --nodes "$NODE1" get routes
talosctl --nodes "$NODE1" get disks
talosctl --nodes "$NODE1" get mounts

# Runtime and capacity
talosctl --nodes "$NODE1" processes
talosctl --nodes "$NODE1" memory
talosctl --nodes "$NODE1" stats
talosctl --nodes "$NODE1" usage
```

When the Kubernetes API is unavailable, inspect its underlying services and
containers through Talos:

```bash
talosctl --nodes "$NODE1" service etcd
talosctl --nodes "$NODE1" logs etcd --tail 100
talosctl --nodes "$NODE1" etcd status
talosctl --nodes "$NODE1" etcd alarm list
talosctl --nodes "$NODE1" service containerd
talosctl --nodes "$NODE1" containers --kubernetes
```

For network incidents, inspect state first and capture packets to the local
workstation instead of installing tools on the node:

```bash
talosctl --nodes "$NODE1" netstat --all
talosctl --nodes "$NODE1" pcap --interface enp1s0 \
  --output talos-node-1.pcap
```

Collect a support bundle before rebooting or restarting services, because a
recovery action can erase useful evidence:

```bash
talosctl support --nodes "$NODE1,$NODE2,$NODE3" \
  --output talos-support.zip
```

Treat support bundles as sensitive operational data. If the Talos API itself is
unreachable, use the local video console, hypervisor console, or out-of-band KVM.
Keep tested copies of the machine configurations, `talosconfig`, etcd snapshots,
and node replacement procedure outside the cluster.

## Networking and Secure Remote Access

### Cilium and Kubernetes Networking

Cilium can replace the default CNI and `kube-proxy`, enforce NetworkPolicy, and
provide LoadBalancer IPAM, layer-2 announcements, Gateway API, and Hubble flow
visibility. Plan the following before bootstrap or migration:

- reserve a LoadBalancer range outside DHCP;
- include the required Cilium machine configuration patch when generating nodes;
- validate pod and service CIDRs;
- test DNS, Services, LoadBalancers, and NetworkPolicy after installation;
- preserve quorum by changing one control-plane node at a time.

If Tailscale traffic enters through `tailscale0`, include that interface in
Cilium's device list. Pin the intended Cilium MTU rather than allowing the
Tailscale interface's smaller MTU to resize the pod network unexpectedly.

### Configuring Tailscale on Talos

Tailscale runs as a Talos system extension, not as a package installed on the
immutable host. Build a Talos Image Factory schematic containing the official
extension:

```yaml
customization:
  systemExtensions:
    officialExtensions:
      - siderolabs/tailscale
```

```bash
curl --silent --request POST --data-binary @tailscale/schematic.yaml \
  https://factory.talos.dev/schematics
```

Use the returned schematic ID to construct the installer image for the exact
Talos version being deployed:

```text
factory.talos.dev/metal-installer/<schematic-id>:<talos-version>
```

Configure the extension **before** upgrading a running node to that image. Store
the rendered configuration outside Git because it contains the auth key:

```yaml
apiVersion: v1alpha1
kind: ExtensionServiceConfig
name: tailscale
environment:
  - TS_AUTHKEY=<tailscale-auth-key>
  - TS_HOSTNAME=node-1
  - TS_ROUTES=192.168.1.111/32,192.168.1.112/32,192.168.1.113/32,192.168.1.200/32,192.168.1.201/32
  - TS_ACCEPT_DNS=false
  - TS_AUTH_ONCE=true
```

Also constrain Kubernetes and etcd to the LAN. Otherwise a node may advertise
its Tailscale `100.x` address as its Kubernetes internal IP or etcd peer address:

```yaml
machine:
  kubelet:
    nodeIP:
      validSubnets:
        - 192.168.1.0/24
cluster:
  etcd:
    advertisedSubnets:
      - 192.168.1.0/24
```

Apply the node-specific extension configuration and LAN-address patch without a
reboot, then upgrade one node at a time with the custom installer image:

```bash
talosctl --nodes "$NODE1" patch machineconfig \
  --patch @tailscale/node-ip.yaml \
  --patch @tailscale/node-1.yaml \
  --mode no-reboot

talosctl --nodes "$NODE1" upgrade \
  --image factory.talos.dev/metal-installer/<schematic-id>:<talos-version>
kubectl wait --for=condition=Ready node/node-1 --timeout=10m
```

Verify that the extension runs while Kubernetes and etcd keep their LAN
addresses:

```bash
talosctl --nodes "$NODE1" get extensions
talosctl --nodes "$NODE1" services
kubectl get nodes -o wide
talosctl --nodes "$NODE1" etcd members
```

Every later Talos upgrade must continue using an installer image containing the
required extensions. Revoke the reusable Tailscale auth key after all nodes have
joined; the nodes retain their state.

### Secure Remote Access Without Exposing Ports

Advertise only the routes remote operators need, preferably individual `/32`
addresses rather than the entire home LAN:

- three node addresses for the Talos API on TCP `50000`;
- the Kubernetes API VIP on TCP `6443`;
- the internal Gateway on TCP `80` and `443`.

Approve only those routes in the Tailscale policy and restrict tailnet members to
the matching destination ports. Deny access to the router and unrelated LAN
devices. Linux clients must enable route acceptance:

```bash
sudo tailscale up --accept-routes
tailscale status
```

All three nodes may advertise the same routes so Tailscale can fail over between
subnet routers. Test from outside the home network, then reboot the active router
and confirm that API and application traffic recover through another node.

## Sources

- [Talos homelab repository](https://github.com/prateekjaindev/homelab)
- [Building a 3-node highly available Kubernetes homelab with Talos Linux](https://blog.prateekjain.dev/building-a-3-node-highly-available-kubernetes-homelab-with-talos-linux-0372066fe49c?sk=4c66cf9181999f9db19ac3aacabcd8e8)
- [Tailscale on Talos Linux](https://blog.prateekjain.dev/tailscale-on-talos-linux-secure-remote-access-to-a-kubernetes-homelab-8a082d903682?sk=c4ec5ac1e782a83b5dc785211d9fd082)
- [From hardened Ubuntu nodes to Talos Linux](https://schoenwald.aero/posts/2026-07-26_from-ubuntu-to-talos/)
- [Debugging Talos Linux without SSH](https://schoenwald.aero/posts/2026-07-28_debugging-talos/)
- [Official Talos documentation](https://docs.siderolabs.com/talos/)
