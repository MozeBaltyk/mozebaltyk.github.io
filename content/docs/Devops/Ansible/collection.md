---
date: 2023-08-01T21:00:00+08:00
title: Collection
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - Devops
tags:
  - Ansible
  - ConfigManager
---

* List 

```bash
ansible-galaxy collection list
```

* Install an Ansible Collection 

```bash
# From Ansible Galaxy official repo
ansible-galaxy collection install community.general

# From a tarball locally
ansible-galaxy collection install ./community-general-6.0.0.tar.gz

# From custom Repo
ansible-galaxy collection install git+https://git.example.com/projects/namespace.collectionName.git
ansible-galaxy collection install git+https://git.example.com/projects/namespace.collectionName,v1.0.2
ansible-galaxy collection install git+https://git.example.com/namespace/collectionName.git

# From a requirement.yml file
ansible-galaxy collection install -r ./requirement.yaml
```

* Requirement file to install Ansible Collection

```yaml
collections:
- name: kubernetes.core

- source: https://gitlab.example.com/super-group/collector.git
  type: git
  version: "v1.0.6"

- source: https://gitlab.ipolicedev.int/another-projects/plates.git
  type: git
```
