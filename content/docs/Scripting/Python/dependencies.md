---
date: 2023-08-01T21:00:00+08:00
title: 🔗 Dependencies
navWeight: 90 # Upper weight gets higher precedence, optional.
series:
  - Devops
categories:
  - Docs
tags:
  - Scripting
  - Python
  - Repository
---


## Package with pip3

```bash
pip3 freeze netaddr > requirements.txt
pip3 download -r requirements.txt -d wheel
mv requirements.txt wheel
tar -zcf wheelhouse.tar.gz wheel
tar -zxf wheelhouse.tar.gz
pip3 install -r wheel/requirements.txt --no-index --find-links wheel
```

## Package with Poetry

```bash
curl -sSL https://install.python-poetry.org | python3 -
poetry new rp-poetry
poetry add ansible
poetry add poetry
poetry add netaddr
poetry add kubernetes
poetry add jsonpatch
poetry add `cat ~/.ansible/collections/ansible_collections/kubernetes/core/requirements.txt`   

poetry build

pip3 install dist/rp_poetry-0.1.0-py3-none-any.whl

poetry export --without-hashes -f requirements.txt -o requirements.txt
```

## Push dans Nexus 

```bash
poetry config repositories.test http://localhost
poetry publish -r test
```

## Images Builder

```bash
podman login registry.redhat.io
podman pull registry.redhat.io/ansible-automation-platform-22/ansible-python-base-rhel8:1.0.0-230

pyenv local 3.9.13
python -m pip install poetry
poetry init
poetry add ansible-builder 
```
