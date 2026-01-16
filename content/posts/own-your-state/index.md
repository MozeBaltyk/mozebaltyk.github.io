---
title: ⛄ Own your terraform state (with s3cmd)
date: 2025-05-05T03:48:10+02:00
noindex: false
featured: true
draft: false
comment: true
toc: true
reward: true
pinned: false
carousel: true
series:
  - Devops
categories:
  - Posts
tags:
  - Terraform
  - Devops
authors:
  - mozebaltyk
images: [./own-your-state/carousel.webp]
sidebar: false
---

What if you do not want to use Terraform cloud ?...

<!--more-->

Recently I was reading this article about [Terraform Cloud](https://blog.puvvadi.me/posts/getting-started-terraform-cloud/), and remembered that I went throught same issue when writing my github Workflows...

## The issue...

When using CI, each job is a runner, so new triggered container for each step of the pipeline. So the `terraform.tfstate` is lost between the pipeline steps. In my case, I was deploying on *Digital Ocean* providers, willing to store the state on S3 bucket created at the start of the pipeline and destroyed at the end. 

I wrote a documentation about `s3cmd` which cover 3 differents use cases (manual usage; in a github workflow; or mounting S3 bucket as a FS) in `docs/storage/s3`. The purpose of this article is not to repeat the documentation but rather underline the fact that we don't need this dependence to *Terraform Cloud* and another account somewhere else, when `s3cmd` can help us to do the job.

## The solution!

### The big steps

* Install and init a connection with `s3cmd`
* Create a bucket
* Use it as your terrafrom backend
* Cleanup after if needed.

### Inside a *Github Workflows*:

This is pretty usefull in a pipeline, but do not forget to include a job to cleanup everything once done...

* Set the vars in the repository config and use them in the *Github Workflows*:

```yaml 
env:
  DO_PAT: ${{secrets.DIGITALOCEAN_ACCESS_TOKEN}}
  AWS_ACCESS_KEY_ID: ${{secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN}}
  AWS_SECRET_ACCESS_KEY: ${{secrets.DIGITALOCEAN_SPACES_SECRET_KEY}}
  REGION: ${{secrets.DIGITALOCEAN_REGION}}
  MOUNT_POINT: "/opt/rkub"
  BUCKET: "rkub-github-action-${{ github.run_id }}"
```

* Create a bucket directly on your provider :

```yaml
    steps:
      - name: Set up S3cmd cli tool
        uses: s3-actions/s3cmd@main
        with:
          provider: digitalocean
          region: ${{secrets.DIGITALOCEAN_REGION}}
          access_key: ${{secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN}}
          secret_key: ${{secrets.DIGITALOCEAN_SPACES_SECRET_KEY}}

      - name: Create Space Bucket
        run: |
          ## sed -i -e 's/signature_v2.*$/signature_v2 = True/' ~/.s3cfg
          ## sed -i -e 's/signature_v2.*$/signature_v2 = True/' /home/runner/work/_temp/s3cmd.conf
          if [[ $BUCKET != "terraform-backend-github" ]]; then s3cmd mb s3://${BUCKET}; fi
          sleep 10
```

* Then use it as *terraform*/*opentofu* backend:

```yaml
    steps:
      - name: Checkout files
        uses: actions/checkout@v4

      - name: Setup Tofu
        uses: opentofu/setup-opentofu@v1
        with:
          tofu_version: "1.7.3"

      - name: Tofu Init
        id: init
        run: |
          cd ./DO/infra
          tofu init -backend-config="bucket=${BUCKET}"

      - name: Tofu Validate
        id: validate
        run: |
          cd ./DO/infra
          tofu validate -no-color

      - name: Tofu Plan
        id: plan
        run: |
          cd ./DO/infra
          tofu plan -out=terraform.tfplan \
          -var "GITHUB_RUN_ID=$GITHUB_RUN_ID" \
          -var "token=${DO_PAT}" \
          -var "worker_count=${WORKER_COUNT}" \
          -var "controller_count=${CONTROLLER_COUNT}" \
          -var "instance_size=${SIZE}" \
          -var "spaces_access_key_id=${{secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN}}" \
          -var "spaces_access_key_secret=${{secrets.DIGITALOCEAN_SPACES_SECRET_KEY}}" \
          -var "mount_point=${MOUNT_POINT}" \
          -var "airgap=${AIRGAP}" \
          -var "terraform_backend_bucket_name=${BUCKET}"
        continue-on-error: true

      - name: Tofu Plan Status
        if: steps.plan.outcome == 'failure'
        run: exit 1

      - name: Tofu Apply
        run: |
          cd ./DO/infra
          tofu apply terraform.tfplan
```

Doing so, I was able to pass the state throught the different jobs in my pipeline. Instead of doing one big job with all the steps, I found this solution more elegant.   

## The full Pipeline

Below the full pipeline *Github Workflow* from the **Rkub** project:

```yaml
---
name: Stage online install

on:
  workflow_dispatch:

env:
  DO_PAT: ${{secrets.DIGITALOCEAN_ACCESS_TOKEN}}
  AWS_ACCESS_KEY_ID: ${{secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN}}
  AWS_SECRET_ACCESS_KEY: ${{secrets.DIGITALOCEAN_SPACES_SECRET_KEY}}
  REGION: ${{secrets.DIGITALOCEAN_REGION}}
  MOUNT_POINT: "/opt/rkub"
  BUCKET: "rkub-github-action-${{ github.run_id }}"
  #BUCKET: "terraform-backend-github"
  CONTROLLER_COUNT: "1"
  WORKER_COUNT: "1"
  SIZE: "s-2vcpu-4gb"
  AIRGAP: "false"

jobs:
  bucket:
    name: Bucket
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - name: Set up S3cmd cli tool
        uses: s3-actions/s3cmd@main
        with:
          provider: digitalocean
          region: ${{secrets.DIGITALOCEAN_REGION}}
          access_key: ${{secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN}}
          secret_key: ${{secrets.DIGITALOCEAN_SPACES_SECRET_KEY}}

      - name: Create Space Bucket
        run: |
          ## sed -i -e 's/signature_v2.*$/signature_v2 = True/' ~/.s3cfg
          ## sed -i -e 's/signature_v2.*$/signature_v2 = True/' /home/runner/work/_temp/s3cmd.conf
          if [[ $BUCKET != "terraform-backend-github" ]]; then s3cmd mb s3://${BUCKET}; fi
          sleep 10

  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    needs: [ Bucket ]
    timeout-minutes: 20

    defaults:
      run:
        shell: bash
        working-directory: ./test

    steps:
      - name: Checkout files
        uses: actions/checkout@v4

      - name: Setup Tofu
        uses: opentofu/setup-opentofu@v1
        with:
          tofu_version: "1.7.3"

      - name: Tofu Init
        id: init
        run: |
          cd ./DO/infra
          tofu init -backend-config="bucket=${BUCKET}"

      - name: Tofu Validate
        id: validate
        run: |
          cd ./DO/infra
          tofu validate -no-color

      - name: Tofu Plan
        id: plan
        run: |
          cd ./DO/infra
          tofu plan -out=terraform.tfplan \
          -var "GITHUB_RUN_ID=$GITHUB_RUN_ID" \
          -var "token=${DO_PAT}" \
          -var "worker_count=${WORKER_COUNT}" \
          -var "controller_count=${CONTROLLER_COUNT}" \
          -var "instance_size=${SIZE}" \
          -var "spaces_access_key_id=${{secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN}}" \
          -var "spaces_access_key_secret=${{secrets.DIGITALOCEAN_SPACES_SECRET_KEY}}" \
          -var "mount_point=${MOUNT_POINT}" \
          -var "airgap=${AIRGAP}" \
          -var "terraform_backend_bucket_name=${BUCKET}"
        continue-on-error: true

      - name: Tofu Plan Status
        if: steps.plan.outcome == 'failure'
        run: exit 1

      - name: Tofu Apply
        run: |
          cd ./DO/infra
          tofu apply terraform.tfplan

      # Save Artifacts
      - name: Install s3fs-fuse on Ubuntu
        run: |
          sudo apt-get install -y s3fs

      - name: Mount Space Bucket
        run: |
          echo "${{secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN}}:${{secrets.DIGITALOCEAN_SPACES_SECRET_KEY}}" > ./passwd-s3fs
          chmod 600 ./passwd-s3fs
          mkdir -p ${MOUNT_POINT}
          s3fs ${BUCKET} ${MOUNT_POINT} -o url=https://${REGION}.digitaloceanspaces.com -o passwd_file=./passwd-s3fs
          df -Th ${MOUNT_POINT}

      - name: Save files
        run: |
          cp ${{ github.workspace }}/test/inventory/hosts.ini ${MOUNT_POINT}/hosts.ini
          cp ${{ github.workspace }}/test/DO/infra/.key.private ${MOUNT_POINT}/.key.private

  reachable:
    name: Reachable
    runs-on: ubuntu-latest
    needs: [ Deploy ]
    timeout-minutes: 10

    defaults:
      run:
        shell: bash
        working-directory: ./test

    steps:
      - name: Checkout files
        uses: actions/checkout@v4

      # Get Artifacts 
      - name: Install s3fs-fuse on Ubuntu
        run: |
          sudo apt-get install -y s3fs

      - name: Mount Space Bucket
        run: |
          echo "${{secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN}}:${{secrets.DIGITALOCEAN_SPACES_SECRET_KEY}}" > ./passwd-s3fs
          chmod 600 ./passwd-s3fs
          mkdir -p ${MOUNT_POINT}
          s3fs ${BUCKET} ${MOUNT_POINT} -o url=https://${REGION}.digitaloceanspaces.com -o passwd_file=./passwd-s3fs
          df -Th ${MOUNT_POINT}

      - name: Get Artificats
        run: |
          cp ${MOUNT_POINT}/hosts.ini ${{ github.workspace }}/test/inventory/hosts.ini
          cp ${MOUNT_POINT}/.key.private ${{ github.workspace }}/test/DO/infra/.key.private

      # Test
      - name: Set up Python
        id: setup_python
        uses: actions/setup-python@v5
        with:
          python-version: 3.12

      - name: Install dependencies
        run: |
          python3 -m pip install --upgrade pip
          python3 -m pip install "ansible-core>=2.15,<2.17"
          ansible --version

      - name: Test if reachable
        run: |
          ANSIBLE_HOST_KEY_CHECKING=False ansible RKE2_CLUSTER -m ping -u root

      - name: Wait for cloud-init to finish
        run: |
          ANSIBLE_HOST_KEY_CHECKING=False ansible RKE2_CLUSTER -m shell -a "cloud-init status --wait" -u root -v

  install:
    name: Install
    runs-on: ubuntu-latest
    needs: [ Reachable ]
    timeout-minutes: 60

    defaults:
      run:
        shell: bash
        working-directory: ./test

    steps:
      - name: Checkout files
        uses: actions/checkout@v4

      - name: Install requirements
        run: |
          cd ..
          make prerequis
          ansible --version

      - name: Install dependencies
        run: |
          python3 -m pip install --upgrade pip
          python3 -m pip install "ansible-core>=2.15,<2.17"
          ansible --version

      # Get Artifacts 
      - name: Install s3fs-fuse on Ubuntu
        run: |
          sudo apt-get install -y s3fs

      - name: Mount Space Bucket
        run: |
          echo "${{secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN}}:${{secrets.DIGITALOCEAN_SPACES_SECRET_KEY}}" > ./passwd-s3fs
          chmod 600 ./passwd-s3fs
          mkdir -p ${MOUNT_POINT}
          s3fs ${BUCKET} ${MOUNT_POINT} -o url=https://${REGION}.digitaloceanspaces.com -o passwd_file=./passwd-s3fs
          df -Th ${MOUNT_POINT}

      - name: Get Artificats
        run: |
          cp ${MOUNT_POINT}/hosts.ini ${{ github.workspace }}/test/inventory/hosts.ini
          cp ${MOUNT_POINT}/.key.private ${{ github.workspace }}/test/DO/infra/.key.private

      # Install
      - name: Run playbook install.yml
        run: |
          ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root playbooks/install.yml -e "airgap=false" -e "method=tarball"

      #- name: Run playbook rancher.yml
      #  run: |
      #    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root playbooks/rancher.yml

      #- name: Run playbook longhorn.yml
      #  run: |
      #    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root playbooks/longhorn.yml

      #- name: Run playbook neuvector.yml
      #  run: |
      #    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root playbooks/neuvector.yml

  test:
    name: Test
    runs-on: ubuntu-latest
    needs: [ Install ]
    timeout-minutes: 10

    defaults:
      run:
        shell: bash
        working-directory: ./test

    steps:
      - name: Checkout files
        uses: actions/checkout@v4

      # Get Artifacts 
      - name: Install s3fs-fuse on Ubuntu
        run: |
          sudo apt-get install -y s3fs

      - name: Mount Space Bucket
        run: |
          echo "${{secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN}}:${{secrets.DIGITALOCEAN_SPACES_SECRET_KEY}}" > ./passwd-s3fs
          chmod 600 ./passwd-s3fs
          mkdir -p ${MOUNT_POINT}
          s3fs ${BUCKET} ${MOUNT_POINT} -o url=https://${REGION}.digitaloceanspaces.com -o passwd_file=./passwd-s3fs
          df -Th ${MOUNT_POINT}

      - name: Get Artificats
        run: |
          cp ${MOUNT_POINT}/hosts.ini ${{ github.workspace }}/test/inventory/hosts.ini
          cp ${MOUNT_POINT}/.key.private ${{ github.workspace }}/test/DO/infra/.key.private

      # Test
      - name: Install dependencies
        run: |
          python3 -m pip install --upgrade pip
          python3 -m pip install "ansible-core>=2.15,<2.17"
          python3 -m pip install -U pytest-testinfra pytest-sugar pytest
          ansible --version

      - name: Run Python Tests
        run: |
          export DEFAULT_PRIVATE_KEY_FILE=.key
          python3 -m pytest --hosts=RKE2_CONTROLLERS --ansible-inventory=inventory/hosts.ini --force-ansible --connection=ansible basic_server_tests.py
          python3 -m pytest --hosts=RKE2_WORKERS --ansible-inventory=inventory/hosts.ini --force-ansible --connection=ansible basic_agent_tests.py

  delay:
    name: Delay
    runs-on: ubuntu-latest
    needs: [ Test ]
    if: always()

    steps:
      - name: Delay 10min
        uses: whatnick/wait-action@master
        with:
          time: '600s'

  cleanup:
    name: Cleanup
    runs-on: ubuntu-latest
    needs: [ Delay ]
    if: always()
    timeout-minutes: 30

    defaults:
      run:
        shell: bash
        working-directory: ./test/DO/infra

    steps:
      - name: Checkout files
        uses: actions/checkout@v4

      - name: Setup Tofu
        uses: opentofu/setup-opentofu@v1
        with:
          tofu_version: "1.7.3"

      - name: Tofu Init
        id: init
        run: |
          tofu init -backend-config="bucket=${BUCKET}"
        continue-on-error: true

      - name: Tofu plan delete stack
        id: plan
        run: |
          tofu plan -destroy -out=terraform.tfplan \
          -var "GITHUB_RUN_ID=$GITHUB_RUN_ID" \
          -var "token=${DO_PAT}" \
          -var "worker_count=${WORKER_COUNT}" \
          -var "controller_count=${CONTROLLER_COUNT}" \
          -var "instance_size=${SIZE}" \
          -var "spaces_access_key_id=${{secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN}}" \
          -var "spaces_access_key_secret=${{secrets.DIGITALOCEAN_SPACES_SECRET_KEY}}" \
          -var "mount_point=${MOUNT_POINT}" \
          -var "airgap=${AIRGAP}" \
          -var "terraform_backend_bucket_name=${BUCKET}"
        continue-on-error: true

      - name: Tofu Apply
        run: |
          tofu apply terraform.tfplan
        continue-on-error: true

      - name: Set up S3cmd cli tool
        uses: s3-actions/s3cmd@main
        with:
          provider: digitalocean
          region: ${{secrets.DIGITALOCEAN_REGION}}
          access_key: ${{secrets.DIGITALOCEAN_SPACES_ACCESS_TOKEN}}
          secret_key: ${{secrets.DIGITALOCEAN_SPACES_SECRET_KEY}}

      - name: Remove Space bucket
        run: |
          ## sed -i -e 's/signature_v2.*$/signature_v2 = True/' ~/.s3cfg
          ## sed -i -e 's/signature_v2.*$/signature_v2 = True/' /home/runner/work/_temp/s3cmd.conf
          if [[ $BUCKET != "terraform-backend-github" ]]; then s3cmd rb s3://${BUCKET} --recursive; fi
          sleep 10
```


