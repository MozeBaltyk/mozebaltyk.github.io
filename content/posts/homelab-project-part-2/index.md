---
title: 🚀 A journey to my homelab. - Part 2
description: "A journey to my homelab..."
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
- **Switch:** Basic unmanaged 5-port Gigabit Ethernet switch.
- **Cluster:** Three HP Mini nodes connected to the switch, running OKD.

Nothing fancy, but it should be enough to get started.

The objective isn't to design the perfect network from day one. It's to provide the services OKD needs, understand how the different components interact, and gradually automate the configuration.

### Network Services for OKD

One interesting aspect of running OKD on bare metal is that several networking services normally provided by a cloud platform become my responsibility.

For this setup, I'm considering the following services:

| Service | Responsibility |
|---|---|
| DNS / Unbound | Resolve cluster API endpoints, node hostnames, reverse DNS, and application wildcard records |
| DHCP | Assign IP addresses and potentially maintain reservations for the nodes |
| Routing / Firewall | Provide internet access and control traffic between networks |
| HAProxy | Load balance access to the OKD API and application ingress endpoints |
| PXE / HTTP boot | Optionally automate node installation and provisioning |

pfSense could handle DNS, DHCP, routing, and firewall rules directly.

HAProxy could potentially run on pfSense through an additional package, although running it separately would also be an option.

The provisioning infrastructure is another question. A PXE or HTTP-based boot service could simplify reinstalling nodes, but it doesn't necessarily need to run on pfSense.

For now, I'd prefer to keep as few external dependencies as possible while maintaining a clear separation between the services required to bootstrap OKD and the services running inside the cluster.

This is also an opportunity to explore infrastructure automation. I'd like to make DNS records, DHCP reservations, firewall rules, and load balancer configuration as reproducible as possible.

### What About Future Network Upgrades?

The initial 1 GbE network should be sufficient to get the cluster running, but there are a few possible improvements worth considering.

**Moving to 2.5 GbE or 10 GbE**

The HP Mini G6 machines may support a 2.5 GbE adapter through their Flex IO expansion slots, depending on the exact configuration.

Combined with a multigigabit switch, this could increase bandwidth between the OKD nodes.

That might become useful for:

- Communication between cluster nodes.
- Distributed storage, particularly if I experiment with Ceph or ODF.
- Large container image and data transfers.
- A future NAS or dedicated storage server.

A switch with a 10 GbE SFP+ uplink would also provide an interesting upgrade path, particularly for a storage server or another switch.

One possibility would be to introduce a small 2.5 GbE switch for the cluster while keeping the original Gigabit switch for less demanding devices.

I've also considered an inexpensive UGREEN 8-port PoE Gigabit switch with two Gigabit uplinks, costing around €40. It could be useful as a secondary switch, although it wouldn't provide 2.5 GbE connectivity.

Of course, this is still hypothetical. I don't yet know whether networking will become a bottleneck, and upgrading before measuring anything would probably be premature.

**VLANs and Network Segmentation**

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

**Managed Switches and Network Visibility**

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

The initial architecture would look something like this:

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

HAProxy would provide the external load balancing required to reach the Kubernetes API and application ingress endpoints. Its actual location is still to be decided: it could run on pfSense or on a separate machine or VM.

Likewise, a provisioning server and NetBird subnet router could remain external components, depending on how far I take the automation and remote-access setup.

### Conclusion

For now, I'll stick with the Netgate appliance and a basic Gigabit switch.

The priority is to get OKD running, understand its networking requirements, and automate the infrastructure around it.

Once the cluster is operational, I'll have a better idea of whether I need faster networking, VLANs, or additional monitoring capabilities.

If I do upgrade, I'll evaluate managed switches based on those requirements rather than committing to a particular ecosystem.

After all, the purpose of this homelab isn't to build the most sophisticated network possible. It's to build something I can understand, experiment with, and improve over time.
in comparaison network with Talos would look like: 

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

if I try to sumarize:

| Component     | My OKD setup          | Referenced Talos setup    |  
|---------------|-----------------------|---------------------------|
| CNI           |
| ServiceLB     |
| kube API      |
| Ingress       |
| kube-proxy    |
|
