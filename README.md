<h1 style="text-align: center;"><code> MozeBaltyk Blog </code></h1>

[![Deployed](https://github.com/MozeBaltyk/mozebaltyk.github.io/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/MozeBaltyk/mozebaltyk.github.io/actions/workflows/ci-cd.yml)
[![Link](https://img.shields.io/badge/This_Blog-blue.svg)](https://mozebaltyk.github.io/)


## Organisation of this blog

**Series**:
  - SysAdmin
  - DBA
  - Network
  - Devops
  - Homelab
  - Hacking
**Categories**:
  - Docs
  - Posts
  - Projects
**Tags**: 

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

## Code blocks

* Toogle of config files (toml/yaml/json):

```md
{{< bs/config-toggle "params" >}}
hb:
  blog:
    home:
      pinned_posts_position: list
{{< /bs/config-toggle >}}
```

* Some banner for info, warning, etc:

```md
{{< bs/alert info >}}
{{< markdownify >}}
This is the old version of this blog. But last update of hugo version did not work well so I decided to move on to the hbstack theme. I keep this article since it was the first one of this blog. 
{{< /markdownify >}}
{{< /bs/alert >}}
```

## Some good examples with this theme

| Website | source code |
| :-: | :-: |
| https://rootandbeer.com/ | https://github.com/rootandbeer/rootandbeer.github.io |