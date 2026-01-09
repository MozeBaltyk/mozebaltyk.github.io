---
date: 2023-08-01T21:00:00+08:00
title: 👾 Pypi Repository
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Devops
categories:
  - Docs
tags:
  - Scripting
  - Python
---

## Pypi Repo for airgap env

Let's take as an example py dependencies for [Netbox](https://github.com/netbox-community/netbox/blob/v3.7.3/requirements.txt)

```bash
# Tools needed
dnf install -y python3.11
pip install --upgrade pip setuptool python-pypi-mirror twine

# init mirror
python3.11 -m venv mirror
mkdir download

# Get list of Py packages needed
curl raw.githubusercontent.com/netbox-community/netbox/v3.7.3/requirements.txt -o requirements.txt
echo pip >> requirements.txt
echo setuptools >> requirements.txt
echo uwsgi >> requirements.txt

# Make sure repository CA is installed
curl http://pki.server/pki/cacerts/ISSUING_CA.pem -o /etc/pki/ca-trust/source/anchors/issuing.crt
curl http://pki.server/pki/cacerts/ROOT_CA.pem -o /etc/pki/ca-trust/source/anchors/root.crt
update-ca-trust


source mirror/bin/activate
pypi-mirror download -b -d download -r requirements.tx
twine upload  --repository-url https://nexus3.server/repository/internal-pypi/ download/*.whl --cert /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
twine upload  --repository-url https://nexus3.server/repository/internal-pypi/ /download/*.tar.gz --cert /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
```

Then on target host inside `/etc/pip.conf` :

```ini
[global]
index=https://nexus3.server/repository/internal-pypi/
index-url=https://nexus3.server/repository/internal-pypi/simple
trusted-host=nexus3.server
```

## Bonus point

How to finish this Netbox installation :

```bash
# install roles and collections dependencies
ansible-galaxy install geerlingguy.postgresql davidwittman.redis
ansible-galaxy collection install community.postgresql

# latest release is not yet available on ansible galaxy, but is required for newest versions of netbox
curl -L -o ansible-role-netbox.tar.gz https://github.com/lae/ansible-role-netbox/archive/refs/tags/v1.0.6.tar.gz
ansible-galaxy collection install ansible-role-netbox.tar.gz

#Download tar packages for redis and netbox, then store them next to the playbook
curl -L https://github.com/redis/redis/archive/refs/tags/7.2.4.tar.gz -O
curl -L https://github.com/netbox-community/netbox/archive/refs/tags/v3.7.3.tar.gz -O
```

* prepare `netbox-vars.yml` :

```yaml
var_hostname: cmdb01-server
var_domain: example.com
postgresql_version: "15"
netbox_python_packages:
  - python3.11
  - python3.11-devel
  - python3.11-setuptools
  - python3.11-psycopg2
  - python3.11-pip
netbox_python_binary: /usr/bin/python3.11
netbox_cert: "{{ lookup('hashi_vault', 'secret=kv/data/mgt/cmdb:ssl_cert') }}"
netbox_key: "{{ lookup('hashi_vault', 'secret=kv/data/mgt/cmdb:ssl_key') }}"
redis_bind: 127.0.0.1
redis_version: "7.2.4"
redis_tarball: "redis-{{ redis_version }}.tar.gz"
netbox_stable: true
netbox_database_socket: "{{ postgresql_unix_socket_directories[0] }}"
netbox_superuser_password: "{{ lookup('hashi_vault', 'secret=kv/data/mgt/cmdb:admin_password') }}"
netbox_socket: "127.0.0.1:8000"
netbox_protocol: uwsgi
netbox_git: false
netbox_install_epel: false
netbox_stable_version: "3.7.3"
netbox_stable_uri: "/tmp/netbox-{{ netbox_stable_version }}.tar.gz"
netbox_config:
  ALLOWED_HOSTS:
    - {{ var_hostname }}.{{ var_domain }}
    - {{ var_hostname }}
    - netbox.{{ var_domain }}
    - netbox
  MEDIA_ROOT: "{{ netbox_shared_path }}/media"
  REPORTS_ROOT: "{{ netbox_shared_path }}/reports"
  SCRIPTS_ROOT: "{{ netbox_shared_path }}/scripts"
postgresql_users:
  - name: "{{ netbox_database_user }}"
    role_attr_flags: CREATEDB,NOSUPERUSER
```

* prepare playbooks

```yaml
---
- name: install netbox
  hosts: "{{ var_hostname }}"
  become: yes
  roles:
    - geerlingguy.postgresql
    - davidwittman.redis
    - ansible-role-netbox

  pre_tasks:
    - name: Copy netbox source
      copy:
        src: "netbox-{{ netbox_stable_version }}.tar.gz"
        dest: "{{ netbox_stable_uri }}"
    - name: Set postgresql module stream
      copy:
        content: |
          [postgresql]
          name=postgresql
          stream={{ postgresql_version }}
          profiles=
          state=enabled
        dest: /etc/dnf/modules.d/postgresql.module
        owner: root
        group: root
        mode: 0644
        
  post_tasks:
    - name: Install nginx
      dnf:
        name: nginx
        state: latest
 
    - name: Ensure dirs exist
      file:
        path: "{{ item }}"
        state: directory
      loop:
        - /usr/share/ssl/certs
        - /usr/share/ssl/private
 
    - name: Deploy netbox SSL cert and key
      copy:
        content: "{{ item.src | b64decode }}"
        dest: "{{ item.dest }}"
      loop:
        - src: "{{ netbox_cert }}"
          dest: /usr/share/ssl/certs/netbox.crt
        - src: "{{ netbox_key }}"
          dest: /usr/share/ssl/private/netbox.key
 
    - name: Deploy nginx config
      copy:
        content: |
          server {
              listen       80;
              server_name  {{ var_hostname }},netbox;
              rewrite ^ https://$http_host$request_uri? permanent;    # force redirect http to https
          }
          server {
              listen          443 ssl;
              server_name     {{ var_hostname }},netbox;
 
              access_log      /var/log/nginx/access_ssl.log combined;
              error_log       /var/log/nginx/error_ssl.log error;
 
              client_max_body_size 25m;
              keepalive_timeout 5;
 
              #SSL Settings
              ssl on;
              ssl_certificate /usr/share/ssl/certs/netbox.crt;
              ssl_certificate_key /usr/share/ssl/private/netbox.key;
 
              location /static/ {
                  alias /srv/netbox/current/netbox/static/;
              }
 
              location / {
                  uwsgi_pass 127.0.0.1:8000;
                  include uwsgi_params;
                  proxy_set_header X-Forwarded-Host $http_host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-Proto $scheme;
              }
 
          }
        dest: /etc/nginx/conf.d/netbox.conf
 
    - name: Allow proxy connection
      seboolean:
        name: httpd_can_network_connect
        persistent: true
        state: true
      tags:
        - selinux
 
    - name: Set context for static dir
      sefcontext:
        target: "{{ netbox_home }}/current/netbox/static(/.*)?"
        setype: httpd_sys_content_t
        state: present
      tags:
        - selinux
 
    - name: Apply context
      command: restorecon -irv {{ netbox_home }}/current/netbox/static
      register: restorecon
      changed_when: restorecon.stdout | length > 0
      tags:
        - selinux
 
    - name: Start nginx
      service:
        name: nginx
        state: started
        enabled: true
 
    - name: Allow https
      firewalld:
        service: https
        permanenet: true
        state: enabled
```

* Execute playbook `ansible-playbook netbox.yml -e "@netbox-vars.yml"`
