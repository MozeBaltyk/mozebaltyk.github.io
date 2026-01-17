---
date: 2023-08-01T21:00:00+08:00
title: Pull
navWeight: 10 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - Devops
tags:
  - Ansible
  - ConfigManager
---


* Test locally a playbook

```bash
ansible-pull -U https://github.com/MozeBaltyk/Okub.git ./playbooks/tasks/provision.yml
```

* Inside a cloud-init

```yaml
#cloud-config
timezone: ${timezone}

packages:
  - qemu-guest-agent
  - git

package_update: true
package_upgrade: true


## Test 1
ansible:
  install_method: pip
  package_name: ansible-core
  run_user: ansible
  galaxy:
    actions:
      - ["ansible-galaxy", "collection", "install", "community.general"]
      - ["ansible-galaxy", "collection", "install", "ansible.posix"]
      - ["ansible-galaxy", "collection", "install", "ansible.utils"]
  pull:
    playbook_name: ./playbooks/tasks/provision.yml
    url: "https://github.com/MozeBaltyk/Okub.git"

## Test 2
ansible:
  install_method: pip
  package_name: ansible
  #run_user only with install_method: pip
  run_user: ansible
  setup_controller:
    repositories:
      - path: /home/ansible/Okub
        source: https://github.com/MozeBaltyk/Okub.git
    run_ansible:
      - playbook_dir: /home/ansible/Okub
        playbook_name: ./playbooks/tasks/provision.yml
########
```

* Troubleshooting

```bash
systemctl --failed
systemctl list-jobs --after
journalctl -e
```

Checks user-data and config:

```bash
[root@bastion ~]# sudo cloud-init schema --system
Found cloud-config data types: user-data, network-config

1. user-data at /var/lib/cloud/instances/nocloud/cloud-config.txt:
  Valid schema user-data

2. network-config at /var/lib/cloud/instances/nocloud/network-config.json:
  Valid schema network-config
```

Few troubleshooting commands:

```bash
sudo cloud-init status --long

sudo cloud-init schema --system

sudo cat /var/lib/cloud/instance/user-data.txt
```

Rerun ansible part :

```bash
cloud-init single --name cc_ansible
```

Checks which step take the most time:

```bash
cloud-init analyze blame
```