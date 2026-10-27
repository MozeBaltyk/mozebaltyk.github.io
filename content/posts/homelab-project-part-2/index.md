---
title: 🚀 A journey to my homelab. - Part 2
description: "Which network for a three-node homelab?"
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

Part 1 settled the hardware: three used Mini PCs, bought second-hand on a budget, with an OKD cluster as the goal. This part is about everything between those machines and the internet.

Running Kubernetes on bare metal means the network stops being someone else's problem. DNS, DHCP, load balancing, certificates and the firewall all become services I have to provide, and each of them is a place where the cluster can fail for reasons that have nothing to do with Kubernetes. The interesting question is not how to configure them — it is how much of it is worth automating, and where that automation stops paying for itself.

## What About the Network?

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

pfSense could handle DNS, DHCP, routing, and firewall rules directly. The load balancer is the one service that could live there or somewhere else, and it is worth its own discussion below.

The provisioning infrastructure is another question. A PXE or HTTP-based boot service could simplify reinstalling nodes, but it doesn't necessarily need to run on pfSense. OKD also ships an agent-based installer that boots a discovery ISO and uses one of the control-plane nodes as the rendezvous point, so the bootstrap machine disappears from the install entirely.

For now, I'd prefer to keep as few external dependencies as possible while maintaining a clear separation between the services required to bootstrap OKD and the services running inside the cluster.

This is also an opportunity to explore infrastructure automation. I'd like to make DNS records, DHCP reservations, firewall rules, and load balancer configuration as reproducible as possible.

### Keeping pfSense Reproducible

That is easier said than done. pfSense is configured through its web GUI, and its XML configuration does not take kindly to concurrent writes, so whatever I use has to apply changes deliberately rather than in parallel.

There is no controller worth running inside the cluster for this either: the network device should not depend on the thing it provides connectivity to. So the automation runs from outside, and there are two credible options.

**Ansible, with the [pfsensible.core](https://github.com/pfsensible/core) collection.** It covers firewall rules, aliases, NAT, VLANs, interfaces, DHCP reservations, Unbound records and even HAProxy backends — the broadest coverage I found, and it keeps the network in the same plain-text, reviewable form as the rest of the automation.

**Terraform, with the [marshallford/pfsense](https://registry.terraform.io/providers/marshallford/pfsense) provider.** It covers DNS resolver overrides, DHCP static mappings and firewall IP/port aliases, but not filter rules, NAT, VLANs or HAProxy. It is also still pre-1.0, so breaking changes are expected between minor versions.

The Ansible collection matches everything I said I wanted to automate; Terraform would only cover the DNS and DHCP part, in exchange for state and a plan. For the network layer, Ansible looks like the better fit, with Terraform kept for provisioning the machines themselves.

The cluster stays a consumer of the network rather than its administrator. That is a boundary I'd rather keep.

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

I've looked at UniFi switches, but I'm not convinced they would offer enough value for this particular setup.

UniFi's main attraction seems to be its integrated management ecosystem, especially when combining switches, access points, and gateways.

Since I'm already planning to use pfSense, I wouldn't necessarily benefit from adopting another networking ecosystem just for one switch.

There are also alternatives worth considering, including TP-Link Omada, MikroTik, Netgear, and Zyxel.

Some provide basic VLAN functionality at relatively low prices, while others offer more advanced configuration, centralized management, or automation interfaces.

For my homelab, the ability to configure and monitor the network programmatically might be more interesting than having a polished dashboard.

Ultimately, the choice should depend on the features I need rather than the manufacturer.

A compact managed switch with 2.5 GbE ports, VLAN support, and perhaps a 10 GbE SFP+ uplink could be a sensible future upgrade.

But I don't see a reason to buy one immediately.

### Initial Network Architecture

The initial architecture would look something like this — the same services as the table above, arranged as a topology:

```text
                         Internet
                            |
                     Netgate / pfSense
                            |
          +-----------------+------------------+
          |                 |                  |
      DNS / Unbound    DHCP / Routing     Firewall / NAT
          |                 |                  |
     api / api-int      Node IPs         Internet access
     *.apps / PTR       Reservations     Network isolation
          |                 |                  |
          +-----------------+------------------+
                            |
                       1 GbE Switch
                            |
               +------------+------------+
               |            |            |
          OKD Node 0   OKD Node 1   OKD Node 2
               |            |            |
               +------------+------------+
                            |
                       OKD Cluster
                     OVN-Kubernetes
                     OpenShift Routes


       External / optional infrastructure:
         - HAProxy (API and Ingress load balancing)
         - PXE / HTTP provisioning server
         - NetBird subnet router
```

The diagram is intentionally simplified.

pfSense would provide the network services, while the switch would connect the physical OKD nodes.

Within OKD, OVN-Kubernetes would handle the cluster's internal networking, while OpenShift Routes would expose applications through the cluster ingress infrastructure.

One detail worth remembering: OVN-Kubernetes encapsulates traffic with Geneve, so the pod MTU is around 1400 instead of 1500. Put a VPN on top of that later and the symptom is usually connections that hang rather than fail outright.

HAProxy would provide the external load balancing for the Kubernetes API and application ingress endpoints. pfSense ships an HAProxy package, so it could run there directly, or on a separate machine or VM.

Keeping it on pfSense has an obvious appeal: one box, one backup, one XML configuration that I already plan to automate. The downside is that it puts the load balancer in the same failure domain as the firewall — a pfSense reboot or configuration reload takes the cluster API down with it, and the package's version follows the pfSense release rather than upstream HAProxy.

For completeness, OKD on bare metal also supports a second approach: a virtual IP managed by keepalived and HAProxy directly on the control-plane nodes, with no external load balancer at all. I'm leaning toward keeping the load balancer off pfSense for now — a dedicated HAProxy (VM or container) has its own configuration file, which can live in git and be tested before it goes anywhere near the cluster — but the decision can wait until the cluster exists.

Likewise, a provisioning server and a NetBird subnet router could remain external components, depending on how far I take the automation and remote-access setup. NetBird is a WireGuard-based overlay network: a subnet router there would let me reach the homelab from outside without exposing anything to the internet.

That last part is not strictly necessary, since pfSense can already terminate WireGuard or OpenVPN. A pfSense-based VPN keeps everything on the box I already back up, at the price of a port forward and a dynamic DNS name. NetBird avoids both — the tunnel is outbound-only and access is identity-based — but it is one more dependency to keep running.

### Certificates: Who Owns TLS?

Three different certificates are in play here, and mixing them up is how a homelab ends up with a browser warning nobody ever fixes.

- **pfSense web GUI.** Issued on the appliance, through the ACME package or a local CA. It must not depend on the cluster: the firewall has to be reachable precisely when the cluster is not.
- **`*.apps.<cluster>`.** Issued by cert-manager inside OKD with Let's Encrypt over DNS-01, and set as the ingress controller's default certificate (the Secret has to live in `openshift-ingress`). One wildcard, renewed by the cluster, declared in git.
- **`api.<cluster>`.** Left to the cluster. Clients trust it through the kubeconfig CA, and replacing the API serving certificate buys nothing here.

DNS-01 is what makes this work: Let's Encrypt only reads the `_acme-challenge` TXT record from the public zone, so that zone has to live at a provider with an API. The internal view stays on pfSense — an Unbound domain override for `*.apps` pointing at the router VIP. Split horizon, one zone, no manual steps.

The decision that matters is where TLS stops. If HAProxy on pfSense terminated it, the wildcard would have to live on the appliance too, and I would be exporting a Kubernetes Secret and importing it by hand after every renewal. Instead the frontend passes them through without decrypting anything: plain TCP for 6443, and SNI-based routing for 443 if more than one hostname has to share the port. pfSense never sees the certificate, and the router keeps owning TLS. The integration here is the absence of one.

That also leaves the two sides sharing exactly one thing: the DNS provider token. It is a real credential — it can rewrite records and therefore redirect the domain — so it gets scoped to the single zone and nothing else.

## Network Comparison with Talos

While looking at other homelab architectures, I came across this [Talos-based homelab](https://github.com/prateekjaindev/homelab/tree/main/networking).

What caught my attention was how differently the networking is organized.

Instead of relying primarily on external services such as pfSense and HAProxy, this setup uses Cilium, Kubernetes Gateway API, cert-manager, and Cloudflare Tunnel to manage application networking.

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

To summarize:

| Component  | My OKD setup                                                                 | Referenced Talos setup                    |
|------------|------------------------------------------------------------------------------|-------------------------------------------|
| CNI        | OVN-Kubernetes, built into OKD                                               | Cilium (eBPF)                             |
| kube-proxy | kube-proxy in local mode (iptables/IPVS)                                     | replaced by Cilium                        |
| ServiceLB  | MetalLB operator, if LoadBalancer services are needed                        | Cilium LB IPAM + L2 announcements         |
| kube API   | external HAProxy, or a keepalived VIP on the control-plane nodes              | Cilium LB IPAM VIP                        |
| Ingress    | OpenShift Routes, served by the HAProxy router pods                          | Gateway API, handled by Cilium            |
| TLS        | router wildcard, self-signed by default, replaceable by cert-manager + LE     | cert-manager, Let's Encrypt DNS-01        |
| Node OS    | Fedora CoreOS, kept in shape by the Machine Config Operator                  | Talos Linux: immutable image, API-only, no SSH |
| Provisioning | ignition files and a bootstrap node, discarded once the cluster is up      | machine config YAML applied with `talosctl`; no bootstrap node |
| Upgrades   | ClusterVersionOperator; the MCO drains and reboots one node at a time        | `talosctl upgrade` per node, then `talosctl upgrade-k8s` |
| Platform extras | console, monitoring stack, Routes, SCCs, ImageStreams                  | none: vanilla Kubernetes, everything else is mine to add |
| Portability | OpenShift API surface, not vanilla Kubernetes                              | vanilla Kubernetes                        |
| Debugging  | SSH and `oc debug node`                                                      | no shell: `talosctl logs`, `dmesg`, debug pods |
| Footprint  | roughly 4 vCPU / 16 GB per control-plane node                                | roughly 2 vCPU / 2 GB per node            |

The difference is not only technical. The Talos setup pulls application networking into the cluster: load balancing, ingress, certificates and even the tunnel in, all declared as Kubernetes resources. My OKD setup keeps part of that outside, on pfSense and HAProxy, where it is easier to reason about but also easier to forget to back up.

Which one is better depends on what I want to learn. A cluster that owns its networking is more portable and closer to what a managed cloud gives you; an external layer is simpler to debug when something breaks at 2 a.m.

Beyond the network, the platform rows are the ones that decide the day-to-day. OKD hands me a console, a monitoring stack, an internal registry and an upgrade process that knows which node to reboot next, plus an API surface (Routes, SCCs, ImageStreams) that most enterprise material is written against. Talos hands me a node OS that is nearly impossible to drift, and then leaves monitoring, ingress, certificates and the order in which add-ons get upgraded to me.

The footprint is the practical difference. OKD's control plane has to carry its own monitoring and registry, which is comfortable on three 32 GB Mini PCs and painful on anything smaller, while Talos runs on 2 GB per node and leaves the budget for workloads. Neither is wrong; they optimise for different things — one for a platform that behaves like a product, the other for a node that behaves like a configuration file.

## Limits of This Design

Every choice above is a trade, and it is worth naming what this one does not buy me.

- **One firewall is one point of failure.** There is no CARP pair, so a pfSense reboot takes the cluster API, the ingress endpoints and DNS with it. The OKD nodes keep running; nothing can reach them until the firewall is back. A second appliance and CARP would fix that, at the price of twice the hardware and a second configuration to keep in sync.
- **No native load balancing or BGP.** Service IPs need MetalLB, either in L2 mode (ARP-based failover, no routing) or in BGP mode with the FRR package. pfSense does neither out of the box, so part of the network ends up living inside the cluster after all.
- **The configuration model is a single XML file.** No API unless the REST API package is installed, and no concurrent writes — which is why the automation has to apply changes in order rather than in parallel.
- **The automation depends on packages.** HAProxy, FRR and the REST API are all packages, and packages lag behind CE releases. A pfSense upgrade is therefore a change that can break the IaC, not just the GUI.
- **The appliance has finite headroom.** IDS, VPN and 2.5 GbE all compete for the same CPU, and the cluster's API path is where that would show up first.

None of this disqualifies the setup for a homelab; it is the same list of compromises any single-box network carries. It does mean the "reproducible infrastructure" goal has a boundary: the firewall itself stays a pet, with backups and a manual upgrade path, while everything around it becomes cattle.

## Conclusion

For now, I'll stick with the Netgate appliance and a basic Gigabit switch.

The priority is to get OKD running, understand its networking requirements, and automate the infrastructure around it.

Once the cluster is operational, I'll have a better idea of whether I need faster networking, VLANs, or additional monitoring capabilities.

If I do upgrade, I'll evaluate managed switches based on those requirements rather than committing to a particular ecosystem.

After all, the purpose of this homelab isn't to build the most sophisticated network possible. It's to build something I can understand, experiment with, and improve over time.
