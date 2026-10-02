<h1 style="text-align: center;"><code> Bałtyk Blog </code></h1>

[![Deployed](https://github.com/MozeBaltyk/mozebaltyk.github.io/actions/workflows/gh-pages.yaml/badge.svg)](https://github.com/MozeBaltyk/mozebaltyk.github.io/actions/workflows/gh-pages.yaml)
[![Link](https://img.shields.io/badge/This_Blog-blue.svg)](https://mozebaltyk.github.io/)


## Organisation of this blog

* **Series** (thematic journeys):
  - Workstation
  - Homelab Journey
  - Building This Blog
  - Building a Tool
  - Infrastructure
  - Open Source
  - Docs *(structural)*
  - Projects *(structural)*
* **Categories**:
  - Devops
  - SysAdmin
  - DBA
  - Tutorials
  - Hacking
  - Network
  - Homelab
* **Tags**:
  - Linux
  - Kubernetes
  - Containers
  - Networking
  - Storage
  - Virtualization
  - Security
  - Git
  - IaC
  - Ansible
  - Scripting
  - Shell
  - Windows / WSL
  - Homelab
  - Hugo
  - Databases
  - CI/CD
  - Gitops

## Importants links for this blogs

[theme doc](https://hbstack.dev/)
[theme source](https://github.com/hbstack/theme-cards)
[Examples](https://hbstack.dev/examples/)
[Add/Remove a Module ](https://hbstack.dev/modules/overview/)

## Run it locally

### Manually

```bash
npm ci 
npm run dev
npm run prod
```

### or with docker 

The two way to build it with docker:

* DEV mode
```bash
# run it with the hugo image - closer to the manual way
podman build \
  -t user/my-site:1 \
  --build-arg HUGO_BASEURL=http://localhost:8080 \
  -f Dockerfile.dev

podman run -it -p 1313:1313 --rm localhost/user/my-site:1 hugo server -D
```

* the more clean, slim and ready for deployment way:
```bash
# Build it
podman build \
  -t user/my-site:test \
  --build-arg HUGO_BASEURL=http://localhost:8080 \
  .
# Run it
podman run -p 8080:80 user/my-site:test
# Check it
podman images
podman ps -a
# Clean it
podman rmi $(podman images --filter=reference='*test*' -q)
podman image prune -a -f
```

## Some good examples with this theme

| Website | source code |
| :-: | :-: |
| https://rootandbeer.com/ | https://github.com/rootandbeer/rootandbeer.github.io |