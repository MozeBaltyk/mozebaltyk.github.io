---
date: 2023-08-01T21:00:00+08:00
title:  🎳 Cluster HA
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - RedHat
categories:
  - Systems
---

This was available on RHEL 6/7 

## Checking status of the cluster:

```bash
clustat
clustat -m            # Display status of and exit
clustat -s            # Display status of and exit
clustat -l            # Use long format for services
cman_tool status      # how local record of cluster status
cman_tool nodes       # how local record of cluster nodes
cman_tool nodes -af
ccs_tool lsnode       # List nodes
ccs_tool lsfence      # List fence devices
group_tool            # Displays the status of fence, dlm and gfs groups
group_tool ls         # Displays the list of groups and their membership
```


## Resource Group Control Commands

```bash
clusvcadm -d       # Disable
clusvcadm -e       # Enable
clusvcadm -e -F    # Enable according to failover domain rules
clusvcadm -e -m    # Enable on
clusvcadm -r -m    # Relocate to member>
clusvcadm -R       # Restart a group in place.
clusvcadm -s       # Stop 
```


## Resource Group Locking (for cluster Shutdown / Debugging)

```bash
clusvcadm -l       # Lock local resource group manager. 
                   # This prevents resource groups from starting on the local node.
clusvcadm -S       # Show lock state
clusvcadm -Z       # Freeze group in place
clusvcadm -U       # Unfreeze/thaw group
clusvcadm -u       # Unlock local resource group manager.
                   # This allows resource groups to start on the local node.
clusvcadm -c       # Convalesce (repair, fix) resource group.
                   # Attempts to start failed, non-critical resources within a resource group.
```


## Sources

[Blog](https://dineshjadhav.wordpress.com/linux-cluster-commands/)