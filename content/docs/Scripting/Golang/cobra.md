---
date: 2023-08-01T21:00:00+08:00
title: 🐍 Cobra
navWeight: 90 # Upper weight gets higher precedence, optional.
series:
  - Devops
categories:
  - Docs
tags:
  - Scripting
  - Golang
  - Cobra
---

## A Command Builder for Go

[Usefull](https://www.digitalocean.com/community/tutorials/how-to-use-the-cobra-package-in-go)

* Installation

```bash
# Install GO
GO_VERSION="1.21.0"
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Install Cobra - CLI builder
go install github.com/spf13/cobra-cli@latest
sudo cp -pr ./go /usr/local/.
```

* Init

```bash
mkdir -p ${project} && cd ${project}
go mod init ${project}
cobra-cli init
go build
go install
cobra-cli add timezone
```
