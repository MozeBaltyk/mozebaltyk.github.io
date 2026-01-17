---
date: 2023-08-01T21:00:00+08:00
title: S3 blockstorage
navWeight: 800 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - Devops
tags:
  - Cloud
  - Storage
---

## S3cmd command

S3cmd is a tool to handle blockstorage S3 type.

### Install the command

```bash
# Ubuntu install 
sudo apt-get install s3cmd

# Redhat install
sudo dnf install s3cmd

# or from sources
wget https://sourceforge.net/projects/s3tools/files/s3cmd/2.2.0/s3cmd-2.2.0.tar.gz
tar xzf s3cmd-2.2.0.tar.gz
cd s3cmd-2.2.0
sudo python3 setup.py install
```

### Configure it

* From Cloud providers (for example DO):

- Log in to the DigitalOcean Control Panel.

- Navigate to API > Spaces Access Keys and generate a new key pair.

- Note down the Access Key and Secret Key.

* Auth and config:

```bash
s3cmd --configure 

# Output
Access Key: xxxxxxxxxxxxxxxxxxxxxx
Secret Key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Encryption password is used to protect your files from reading
by unauthorized persons while in transfer to S3
Encryption password: xxxxxxxxxx
Path to GPG program [/usr/bin/gpg]:

When using secure HTTPS protocol all communication with Amazon S3
servers is protected from 3rd party eavesdropping. This method is
slower than plain HTTP and can't be used if you're behind a proxy
Use HTTPS protocol [No]: Yes

New settings:
  Access Key: xxxxxxxxxxxxxxxxxxxxxx
  Secret Key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  Encryption password: xxxxxxxxxx
  Path to GPG program: /usr/bin/gpg
  Use HTTPS protocol: True
  HTTP Proxy server name:
  HTTP Proxy server port: 0

Test access with supplied credentials? [Y/n] Y
Please wait, attempting to list all buckets...
Success. Your access key and secret key worked fine :-)

Now verifying that encryption works...
Success. Encryption and decryption worked fine :-)

Save settings? [y/N] y
Configuration saved to '/root/.s3cfg'
```

### Manage S3 buckets:

```bash
# List
s3cmd ls

# Create if does not already exist
s3cmd info s3://terraform-backend-test || s3cmd mb s3://terraform-backend-test -v -d

# Delete bucket 
s3cmd rb s3://terraform-backend-github-test --recursive

# Get size of the bucket
s3cmd du s3://terraform-backend-test
```

## Use s3cmd in a pipeline 

* in a github Workflows

```yaml
jobs:
  backend:
    name: Backend
    runs-on: ubuntu-latest

    steps:
      - name: Set up S3cmd cli tool
        uses: s3-actions/s3cmd@main
        with:
          provider: digitalocean
          region: FRA1
          access_key: ${{secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN}}
          secret_key: ${{secrets.DIGITALOCEAN_SPACES_SECRET_KEY}}

      - name: Create Space Bucket
        run: |
          sed -i -e 's/signature_v2.*$/signature_v2 = True/' ~/.s3cfg
          buck="github-action-${{ github.run_id }}"
          s3cmd mb s3://$buck
          sleep 10
        continue-on-error: true
```

## Mount S3 bucket as a FS - with s3fs

```bash
# conf epel repo on RHEL8 
cat < EOF > /etc/yum.repos.d/epel.repo
name = "Extra Packages for Enterprise Linux 8 - Release"
baseurl = "http://download.fedoraproject.org/pub/epel/8/Everything/$basearch"
enabled = true
failovermethod = "priority"
gpgcheck = true
gpgkey = "http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8"
EOF

# install packages
dnf install epel-release s3fs-fuse

# Create passwd file
echo "${spaces_access_key_id}:${spaces_access_key_secret}" > /etc/passwd-s3fs
chown root:root /etc/passwd-s3fs
chmod 0600 /etc/passwd-s3fs

# Mount
mkdir /mnt/point
s3fs ${bucket_name} ${mount_point} -o url=https://${region}.digitaloceanspaces.com",
```
