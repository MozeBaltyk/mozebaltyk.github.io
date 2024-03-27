---
date: 2023-08-01T21:00:00+08:00
title: S3
navWeight: 800 # Upper weight gets higher precedence, optional.
series:
  - Cloud
categories:
  - Storage
---


## S3cmd 

```bash
# install 
sudo pip install s3cmd

# config 
s3cmd --configure 

# Create if does not already exist
s3cmd info s3://terraform-backend-test || s3cmd mb s3://terraform-backend-test -v -d

# Delete bucket 
s3cmd rb s3://terraform-backend-github-test --recursive

# Get size of the bucket
s3cmd du s3://terraform-backend-test
```

## S3cmd github action

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

## Mount S3 bucket as a FS

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
