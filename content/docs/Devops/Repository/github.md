---
date: 2023-08-01T21:00:00+08:00
title: 🐈 Github
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Repository
categories:
  - Devops
---


### Install gh
```bash
# ubuntu
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y

# Redhat
sudo dnf install 'dnf-command(config-manager)'
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf install gh
```

### Autocompletions 
 ```bash
 gh completion zsh > $ZSH/completions/_gh
 ```

### Create an ssh key ed

### Login
```bash
gh auth login -p ssh -h GitHub.com -s read:project,delete:repo,repo,workflow -w

gh auth status
github.com
  ✓ Logged in to github.com as MorzeBaltyk ($HOME/.config/gh/hosts.yml)
  ✓ Git operations for github.com configured to use ssh protocol.
  ✓ Token: gho_************************************
  ✓ Token scopes: delete_repo, gist, read:org, read:project, repo
```

### To use your key

One way:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

The best way, set in `~/.ssh/config`:

```bash
# Github
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
```

### create new project
```bash
gh repo create AnsiColt --private --clone -d "For everytime I want to draw a new ansible collection"
git config user.name "MorzeBaltyk"
git config user.email "baltyk@example.com"
```
