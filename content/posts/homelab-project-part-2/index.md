---
title: 🚀 A Journey Through My Homelab - Part 2
description: "What network should I use for a three-node homelab?"
date: 2026-10-20T03:48:10+02:00
noindex: false
featured: true
draft: true
comment: true
toc: true
reward: true
pinned: false
series:
  - Homelab Journey
categories:
  - Reflection
tags:
  - Homelab
authors:
  - mozebaltyk
images:
  - carousel/homelab-part2.webp
sidebar: false
---

Part 1 settled the hardware: three used Mini PCs, bought second-hand on a budget, with an OKD cluster as the goal. This part is about the network.

Running Kubernetes on bare metal means the network stops being someone else's problem. DNS, DHCP, load balancing, certificates, and the firewall all become services I have to provide, and each of them is a place where the cluster can fail for reasons that have nothing to do with Kubernetes. This raises several questions: What hardware do I need? How much can I automate? Do I need services from external providers? Bootstrapping OKD is yet another networking topic...

## So What About the Network?

### The Hardware

I recently inherited a small Netgate appliance from a friend, which runs pfSense.

This is an interesting addition to the homelab, especially since networking is one of the areas I want to explore further.

pfSense comes with several benefits:

- **XML-based configuration:** Settings are stored in a single XML file, which opens up possibilities for configuration templating, backups, and automation.
- **Virtualized testing:** I could experiment with pfSense configurations in a VM before applying them to the physical appliance, provided I account for differences in network interfaces.
- **Integrated networking services:** Firewall, routing, DHCP, DNS through Unbound, and VLAN support.
- **Learning opportunity:** A chance to experiment with network architecture without immediately investing in additional hardware.

The initial hardware setup would therefore remain fairly simple:

- **Router/firewall:** Netgate appliance running pfSense.
- **Switch:** Basic unmanaged 8-port Gigabit Ethernet switch.
- **Cluster:** Three HP Mini nodes (G4 or G6, see [Part 1](../homelab-project/)) connected to the switch, running OKD.

Nothing fancy, but it should be enough to get started.

The objective isn't to design the perfect network from day one. It's to provide the services OKD needs, understand how the different components interact, and gradually automate the configuration.

### Network Services for OKD

One interesting aspect of running OKD on bare metal is that several networking services normally provided by a cloud platform become my responsibility.

For this setup, I'm considering the following services:

| Service | Responsibility |
|---|---|
| DNS / Unbound | Resolve cluster API endpoints, node hostnames, reverse DNS, and application wildcard records |
| DHCP | Assign IP addresses, with permanent reservations for the nodes — OKD expects addresses that never change |
| Routing / Firewall | Provide internet access and control traffic between networks |
| NTP | Keep the nodes' clocks accurate; the control plane dislikes drift |
| HAProxy | Load balance access to the OKD API and application ingress endpoints |
| PXE / HTTP boot | Optionally automate node installation and provisioning |

pfSense can handle DNS, DHCP, routing, and firewall rules directly. I will keep load balancing on a dedicated external HAProxy host so it does not share pfSense's failure domain.

### Bootstrapping and Provisioning Services

ISO or PXE boot? The agent-based installer generates an ISO containing the required configuration, so it does not need a separate HTTPS server for Ignition. However, these Mini PCs have no virtual media and I want to boot all three at once. In practice, that means preparing one USB stick per node. PXE wins here because it makes concurrent installation and later reinstalls more repeatable and convenient.

The provisioning infrastructure is another question. A PXE or HTTP-based boot service could simplify reinstalling nodes, but it doesn't necessarily need to run on pfSense.

Inspired by the [Nixie](https://github.com/khuedoan/nixie) project, I could use my Okub project to create a similar ephemeral PXE server for booting OKD. This solves the "first machine in the data center" problem: in bare-metal setups with persistent PXE servers, you would otherwise need to automate the installation of the PXE server itself.

On the other hand, keeping the PXE artifacts on pfSense could make it possible to reinstall OKD without relying on another machine. I still need to determine whether that benefit justifies running PXE services on pfSense.

For now, I'd prefer to keep as few external dependencies as possible while maintaining a clear separation between the services required to bootstrap OKD and the services running inside the cluster.

OKD's agent-based installer uses one control-plane host as the rendezvous point and does not require a separate bootstrap node. There is no debate about this one: the installation method should be agent-based.

### Keeping pfSense Reproducible

This is also an opportunity to explore infrastructure automation. I'd like to make DNS records, DHCP reservations, firewall rules, and the dedicated HAProxy configuration as reproducible as possible.
In this respect, however, pfSense does not make life easier. The installer is free to download, but the Netgate store and installer workflow complicate automated retrieval.

Then it's configured through its web GUI, and its XML configuration does not take kindly to concurrent writes, so whatever I use has to apply changes deliberately rather than in parallel.

There is no controller worth running inside the cluster for this either: the network device should not depend on the thing it provides connectivity to. So the automation runs from outside, and there are two credible options.

**Ansible, with the [pfsensible.core](https://github.com/pfsensible/core) collection.** It covers firewall rules, aliases, NAT, VLANs, interfaces, DHCP reservations, and Unbound records — the broadest coverage I found, and it keeps the network in the same plain-text, reviewable form as the rest of the automation.

**Terraform, with the [marshallford/pfsense](https://registry.terraform.io/providers/marshallford/pfsense) provider.** It covers DNS resolver overrides, DHCP static mappings and firewall IP/port aliases, but not filter rules, NAT, VLANs or HAProxy. It is also still pre-1.0, so breaking changes are expected between minor versions.

The Ansible collection covers the pfSense configuration I want to automate, and Ansible can also deploy the dedicated HAProxy configuration. Terraform would only cover the DNS and DHCP part, in exchange for state and a plan. For the network layer, Ansible looks like the better fit, with Terraform kept for provisioning the machines themselves.

The cluster stays a consumer of the network rather than its administrator. That is a boundary I'd rather keep.

### Initial Network Architecture

The initial design uses a dedicated HAProxy machine or VM outside the cluster. That keeps load balancing separate from pfSense and makes its configuration a normal file that I can keep in git and validate before deployment.

Here is an illustrative first address plan. These are example values, not addresses from my home network:

| Purpose | Example address or range |
|---|---|
| Homelab subnet | `10.77.0.0/24` |
| pfSense gateway | `10.77.0.1` |
| Dedicated HAProxy | `10.77.0.10` |
| OKD nodes | `10.77.0.21`, `10.77.0.22`, `10.77.0.23` |
| DHCP pool | `10.77.0.100`–`10.77.0.199` |
| `api.okd.lab.example` | `10.77.0.10` |
| `api-int.okd.lab.example` | `10.77.0.10` |
| `*.apps.okd.lab.example` | `10.77.0.10` |

The node and HAProxy addresses sit outside the DHCP pool. In Unbound, the API names can be host overrides, while the application wildcard needs a wildcard/local-zone record. A domain override would mean forwarding a zone to another authoritative DNS server, which is not what this design does.

The topology then looks like this:

```text
                         Internet
                            |
                     Netgate / pfSense
                            |
                DNS / DHCP / routing / firewall
                            |
                       1 GbE switch
              +-------------+-------------+
              |             |             |
      Dedicated HAProxy  OKD nodes   PXE server (when needed)
       10.77.0.10        .21-.23
              |             |
              |             +-- OVN-Kubernetes
              |             +-- OpenShift ingress
              |
              +-- :6443 ----> control-plane API
              +-- :80/:443 --> ingress on the OKD nodes
```

The diagram is intentionally simplified.

pfSense provides DNS, DHCP, routing, and firewall services, while the switch connects HAProxy and the physical OKD nodes. Both `api` names and the `*.apps` wildcard resolve to HAProxy. Port 6443 is balanced across the control-plane API endpoints; ports 80 and 443 are balanced across the nodes running ingress.

Within OKD, OVN-Kubernetes would handle the cluster's internal networking, while OpenShift Routes would expose applications through the cluster ingress infrastructure.

One detail worth remembering: OVN-Kubernetes encapsulates traffic with Geneve, so the pod MTU is around 1400 instead of 1500. Put a VPN on top of that later and the symptom is usually connections that hang rather than fail outright.

This separates the load balancer's failure domain from pfSense, but one HAProxy is still a single point of failure. A second instance with a shared virtual IP could remove that limitation later; it is unnecessary for the initial homelab.

Likewise, a provisioning server and a NetBird subnet router could remain external components, depending on how far I take the automation and remote-access setup. NetBird is a WireGuard-based overlay network: a subnet router there would let me reach the homelab from outside without exposing anything to the internet.

That last part is not strictly necessary, since pfSense can already terminate WireGuard or OpenVPN. A pfSense-based VPN keeps everything on the box I already back up, at the price of a port forward and a dynamic DNS name. NetBird avoids both — the tunnel is outbound-only and access is identity-based — but it is one more dependency to keep running.

### Certificates: Who Owns TLS?

Three different certificates are in play here, and mixing them up is how a homelab ends up with a browser warning nobody ever fixes.

- **pfSense web GUI.** Issued on the appliance, through the ACME package or a local CA. It must not depend on the cluster: the firewall has to be reachable precisely when the cluster is not.
- **`*.apps.<cluster>`.** Issued by cert-manager inside OKD with Let's Encrypt over DNS-01, and set as the ingress controller's default certificate (the Secret has to live in `openshift-ingress`). One wildcard, renewed by the cluster; only the declarative certificate resources belong in git.
- **`api.<cluster>`.** Left to the cluster. Clients trust it through the kubeconfig CA, and replacing the API serving certificate buys nothing here.

DNS-01 is what makes this work: Let's Encrypt only reads the `_acme-challenge` TXT record from the public zone, so that zone has to live at a provider with an API. The internal view stays on pfSense, with an Unbound wildcard/local-zone record pointing `*.apps` at HAProxy. Split horizon, one zone, no manual steps.

The decision that matters is where TLS stops. If HAProxy terminated it, the wildcard would have to live there too, and I would be exporting a Kubernetes Secret and importing it by hand after every renewal. Instead, HAProxy passes the traffic through without decrypting it: TCP for 6443, 80, and 443. Neither pfSense nor HAProxy sees the certificate, and the OpenShift router keeps owning application TLS. The integration here is the absence of one.

The DNS provider token belongs only to cert-manager unless I later add separate public-DNS automation. It is a real credential — it can rewrite records and therefore redirect the domain — so it gets scoped to the required zone and permissions, stored as a Kubernetes Secret, and never committed to git.

### What About Future Network Upgrades?

The initial 1 GbE network should be sufficient to get the cluster running, but there are a few possible improvements worth considering.

#### Moving to 2.5 GbE or 10 GbE

The HP Mini G6 machines may support a 2.5 GbE adapter through their Flex IO expansion slots, depending on the exact configuration.

Combined with a multigigabit switch, this could increase bandwidth between the OKD nodes.

That might become useful for:

- Communication between cluster nodes.
- Distributed storage, particularly if I experiment with Ceph or ODF.
- Large container image and data transfers.
- A future NAS or dedicated storage server.

A switch with a 10 GbE SFP+ uplink would also provide an interesting upgrade path, particularly for a storage server or another switch.

One possibility would be to introduce a small 2.5 GbE switch for the cluster while keeping the original Gigabit switch for less demanding devices.

I've also considered an inexpensive UGREEN 8-port PoE Gigabit switch with two Gigabit uplinks, costing around €40. Nothing in the design draws PoE today, but it leaves room for an access point or a camera later. It could be useful as a secondary switch, although it wouldn't provide 2.5 GbE connectivity.

Of course, this is still hypothetical. I don't yet know whether networking will become a bottleneck, and upgrading before measuring anything would probably be premature.

#### VLANs and Network Segmentation

Another possible improvement would be to separate the homelab into several logical networks:

- **Management:** pfSense, switches, and hypervisor management.
- **OKD:** Cluster nodes and related infrastructure traffic.
- **Home:** Laptops, phones, and other everyday devices.
- **IoT:** Connected devices, if needed later.

pfSense would handle routing and firewall rules between VLANs, while a managed switch would provide Layer 2 segmentation.

For this, I wouldn't need anything particularly sophisticated. A switch supporting IEEE 802.1Q VLANs would already cover the basic requirements.

The main advantage would be isolating the cluster from the rest of the home network without having to introduce dedicated physical switches for every network.

However, VLANs also introduce additional configuration and troubleshooting complexity.

For a three-node OKD cluster, starting with a single network might be more reasonable.

#### Managed Switches and Network Visibility

Beyond VLANs and faster ports, a managed switch could provide useful capabilities such as:

- Port statistics and link monitoring.
- Traffic and error counters.
- Port mirroring for packet captures.
- SNMP or other monitoring interfaces.
- Configuration through a CLI, API, or central controller, depending on the model.

UniFi's main attraction seems to be its integrated management ecosystem, especially when combining switches, access points, and gateways.

There are also alternatives worth considering, including TP-Link Omada, MikroTik, Netgear, and Zyxel.

Some provide basic VLAN functionality at relatively low prices, while others offer more advanced configuration, centralized management, or automation interfaces.

For my homelab, the ability to configure and monitor the network programmatically might be more interesting than having a polished dashboard.

A compact managed switch with 2.5 GbE ports, VLAN support, and perhaps a 10 GbE SFP+ uplink could be a sensible future upgrade. But I don't see a reason to buy one immediately.

## Network Comparison with Talos

While looking at other homelab architectures, I came across this [Talos-based homelab](https://github.com/prateekjaindev/homelab/tree/main/networking). Its application networking lives mostly inside the cluster: Cilium provides pod and Service networking, LoadBalancer addresses, L2 announcements, and Gateway API support, while Cloudflare Tunnel provides an outbound-only path for public applications.

```txt
                       Internet
                          │
                   Cloudflare edge        TLS for *.prateek.cloud
                          │  outbound-only tunnel, no port forwarding
 ┌────────────────────────┼─────────────── CYBERTRON ──────────────┐
 │                 cloudflared ×2                                  │
 │                        │ http                                   │
 │                 Gateway "public"        Gateway "internal" ◄──── 192.168.1.201
 │                 *.prateek.cloud         *.lab.prateek.cloud     │  LAN, HTTPS
 │                        │                       │                │
 │                   public apps          lab apps, dashboards     │
 │                                                                 │
 │  Cilium: pod network · kube-proxy replacement · NetworkPolicy · │
 │          LB IPAM + L2 announcements · Gateway API · Hubble      │
 │  cert-manager: *.lab.prateek.cloud, Let's Encrypt DNS-01        │
 └─────────────────────────────────────────────────────────────────┘
```

The networking differences are:

| Component | My OKD setup | Referenced Talos setup |
|---|---|---|
| Pod and Service networking | OVN-Kubernetes integrates pod networking and Kubernetes Service handling | Cilium uses eBPF and replaces kube-proxy |
| LoadBalancer Services | MetalLB operator, if they are needed | Cilium LB IPAM with L2 announcements |
| Kubernetes API | Dedicated external HAProxy | Talos-managed control-plane VIP at `192.168.1.200`; separate from Cilium LB IPAM |
| Application ingress | OpenShift Routes through router pods, reached via external HAProxy | Gateway API handled by Cilium |
| TLS | Ingress wildcard managed by cert-manager with Let's Encrypt DNS-01 | cert-manager with Let's Encrypt DNS-01 |
| Provisioning | Agent-based ISO or PXE, with a rendezvous control-plane host and no separate bootstrap node | Talos machine configuration applied with `talosctl`; no separate bootstrap node |

The Talos design lets the cluster advertise application endpoints directly on the LAN and sends public traffic through an outbound tunnel. My OKD design keeps the API and ingress entry point outside the cluster on dedicated HAProxy. That external layer is easier for me to inspect independently, but it is another configuration and failure domain to manage.

## Limits of This Design

Every choice above is a trade-off, and it is worth naming what this one does not buy me.

- **One firewall is one point of failure.** There is no CARP pair, so a pfSense reboot interrupts DNS, internet access, and access routed through it. The OKD nodes and dedicated HAProxy keep running, and same-LAN clients may still reach them by address or with cached DNS. A second appliance and CARP would reduce that risk, at the price of twice the hardware and a second configuration to keep in sync.
- **One load balancer is another point of failure.** If the dedicated HAProxy host stops, the API and application entry points stop with it even if pfSense and all three nodes are healthy.
- **No native load balancing or BGP.** Service IPs need MetalLB, either in L2 mode (ARP-based failover, no routing) or in BGP mode with the FRR package. pfSense does neither out of the box, so part of the network ends up living inside the cluster after all.
- **The configuration model is a single XML file.** No API unless the REST API package is installed, and no concurrent writes — which is why the automation has to apply changes in order rather than in parallel.
- **The automation depends on packages.** FRR and the REST API are packages, and packages can lag behind CE releases. A pfSense upgrade is therefore a change that can break the IaC, not just the GUI.
- **The appliance has finite headroom.** IDS, VPN, and 2.5 GbE all compete for the same CPU, which would show up first in internet or routed traffic rather than same-LAN cluster traffic.

None of this disqualifies the setup for a homelab; it is the same list of compromises any single-box network carries. It does mean the "reproducible infrastructure" goal has a boundary: the firewall itself stays a pet, with backups and a manual upgrade path, while everything around it becomes cattle.

## Conclusion

For now, I'll stick with the Netgate appliance and a basic Gigabit switch.

The priority is to get OKD running, understand its networking requirements, and automate the infrastructure around it.

Once the cluster is operational, I'll have a better idea of whether I need faster networking, VLANs, or additional monitoring capabilities.
