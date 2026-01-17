---
date: 2023-08-01T21:00:00+08:00
title: 🔒 Vault on k8s
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - Devops
tags:
  - Kubernetes
  - Infrastructure
  - Secrets
  - Certificate
---

Some time ago, I made a small shell script to handle Vault on a cluster kubernetes. For documentation purpose. 

## Install Vault with helm 

```bash
#!/bin/bash

## Variables 
DIRNAME=$(dirname $0)
DEFAULT_VALUE="vault/values-override.yaml"
NewAdminPasswd="PASSWORD"
PRIVATE_REGISTRY_USER="registry-admin"
PRIVATE_REGISTRY_PASSWORD="PASSWORD"
PRIVATE_REGISTRY_ADDRESS="registry.example.com"
DOMAIN="example.com"
INGRESS="vault.${DOMAIN}"

if [ -z ${CM_NS+x} ];then
  CM_NS='your-namespace'
fi

if [ -z ${1+x} ]; then
  VALUES_FILE="${DIRNAME}/${DEFAULT_VALUE}"
  echo -e "\n[INFO] Using default values file '${DEFAULT_VALUE}'"
else
  if [ -f $1 ]; then
    echo -e "\n[INFO] Using values file $1"
    VALUES_FILE=$1
  else
    echo -e "\n[ERROR] No file exist $1"
    exit 1
  fi
fi

## Functions 
function checkComponentsInstall() {
    componentsArray=("kubectl" "helm")
    for i in "${componentsArray[@]}"; do
      command -v "${i}" >/dev/null 2>&1 ||
        { echo "${i} is required, but it's not installed. Aborting." >&2; exit 1; }
    done
}

function createSecret() {
kubectl get secret -n ${CM_NS} registry-pull-secret --no-headers 2> /dev/null \
|| \
kubectl create secret docker-registry -n ${CM_NS} registry-pull-secret \
  --docker-server=${PRIVATE_REGISTRY_ADDRESS} \
  --docker-username=${PRIVATE_REGISTRY_USER} \
  --docker-password=${PRIVATE_REGISTRY_ADDRESS}
}

function installWithHelm() {
helm dep update ${DIRNAME}/helm

helm upgrade --install vault ${DIRNAME}/helm \
--namespace=${CM_NS} --create-namespace \
--set global.imagePullSecrets.[0]=registry-pull-secret \
--set global.image.repository=${PRIVATE_REGISTRY_ADDRESS}/hashicorp/vault-k8s \
--set global.agentImage.repository=${PRIVATE_REGISTRY_ADDRESS}/hashicorp/vault \
--set ingress.hosts.[0]=${INGRESS} \
--set ingress.enabled=true \
--set global.leaderElection.namespace=${CM_NS}

echo -e "\n[INFO] sleep 30s" && sleep 30
}

checkComponentsInstall
createSecret
installWithHelm
```


## Init Vault on kubernetes

Allow local kubernetes to create and reach secret on the Vault 

```bash
#!/usr/bin/bash

## Variables 
DIRNAME=$(dirname $0)
KEY_SHARES="3"
KEY_THRESHOLD="2"
INIT_LOG="vault.log"

if [ -z ${VAULT_NS+x} ];then
  VAULT_NS='your-namespace'
fi

if [ -z ${1+x} ]; then
  VALUES_FILE="${DIRNAME}/${DEFAULT_VALUE}"
  echo "INFO: Using default values file '${DEFAULT_VALUE}'"
else
  if [ -f $1 ]; then
    echo "INFO: Using values file $1"
    VALUES_FILE=$1
  else
    echo "ERROR: No file exist $1"
    exit 1
  fi
fi

function initVault() {
  while [[ $(kubectl -n ${VAULT_NS} get pod vault-0 --no-headers | awk '{print $3}') != 'Running' ]]; do
    kubectl -n ${VAULT_NS} get pod vault-0 --no-headers; sleep 5;
  done

  if [[ $(kubectl -n ${VAULT_NS} exec vault-0 -- vault status 2> /dev/null | awk '/Initialized / {print $2}') == "true" ]]; then
    echo "Vault is already Initialized!"
  else
    echo "Vault is not init. Start Initializing...";
    kubectl -n ${VAULT_NS} exec -ti vault-0 -- vault operator init -key-shares=${KEY_SHARES} -key-threshold=${KEY_THRESHOLD} > ${INIT_LOG}
  fi
}

function unsealVault() {
  if [[ "$(kubectl -n ${VAULT_NS} exec vault-0 -- vault status 2>/dev/null | awk '/Sealed / {print $2}')" == "false" ]]; then
    echo "Vault already unsealed!"
  else
    if [[ -f "${INIT_LOG}" ]]; then
      arrayOfVaultKeys=()

      echo "Import unseal keys"
      for i in $(seq 1 "$(awk '/Unseal Key/ {print $4}' ${INIT_LOG} | wc -l)"); do
        arrayOfVaultKeys+=("$(awk "/Unseal Key ${i}:/ {print \$4}" ${INIT_LOG})")
      done

      echo "Starting unseal..."
      for i in "${arrayOfVaultKeys[@]}"; do
        if [[ "$(kubectl -n ${VAULT_NS} exec vault-0 -- vault status 2>/dev/null | awk '/Sealed / {print $2}')" == "true" ]]; then
          kubectl -n ${VAULT_NS} exec vault-0 -- vault operator unseal "${i}"
        else
          break
        fi
      done

    else
      echo -e "[ERROR] There is no ${INIT_LOG} file with unseal keys and root token. Aborting."; exit 1;
    fi
  fi
}

function enableVaultK8sAuth() {

  vaultRootToken=$(awk "/Initial Root Token:/ {print \$4}" ${INIT_LOG})
  kubectl -n ${VAULT_NS} exec vault-0 -- vault login "${vaultRootToken}";

  if [[ $(kubectl -n ${VAULT_NS} exec vault-0 -- vault auth list | awk '/kubernetes/ {print $1}') == "kubernetes/" ]]; then
    echo "kubernetes auth already enabled!"
  else

    kubectl -n ${VAULT_NS} exec vault-0 -- vault auth enable kubernetes;
    tokenReviewerJwt=$(kubectl -n ${VAULT_NS} exec vault-0 -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    k8sAddress=$(kubectl -n ${VAULT_NS} exec vault-0 -- ash -c 'echo $KUBERNETES_SERVICE_HOST')

    kubectl -n ${VAULT_NS} exec vault-0 -- vault write auth/kubernetes/config issuer="https://kubernetes.default.svc.cluster.local" \
      token_reviewer_jwt="${tokenReviewerJwt}" \
      kubernetes_host="https://${k8sAddress}:443" \
      kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  fi
}

function addVaultPermission() {
  kubectl -n ${VAULT_NS} exec vault-0 -- ash -c 'cat << EOF > /tmp/policy.hcl
path "avp/data/test" { capabilities = ["read"] }
EOF'

  kubectl -n ${VAULT_NS} exec vault-0 -- vault policy write argocd-repo-server /tmp/policy.hcl

  kubectl -n ${VAULT_NS} exec vault-0 -- vault write auth/kubernetes/role/argocd-repo-server \
  	bound_service_account_names=argocd-repo-server \
    bound_service_account_namespaces=argocd policies=argocd-repo-server
}

function addVaultSecret() {
  if [[ $(kubectl -n ${VAULT_NS} exec vault-0 -- vault secrets list | awk '/avp\// {print $1}') == "avp/" ]]; then
    echo -e "\n[INFO] Vault avp secret path already exist"
  else 
    kubectl -n ${VAULT_NS} exec vault-0 -- vault secrets enable -path=avp -version=2 kv
  fi
    kubectl -n ${VAULT_NS} exec vault-0 -- vault kv put avp/test sample=secret
}


function testSampleSecret() {
  if [[ $(kubectl -n default get secret example-secret -o jsonpath='{.data}') == '{"sample-secret":"c2VjcmV0"}' ]]; then
    echo -e "\n[OK] Secret created successfully"
  else
    echo -e "\n[ERROR] FAIL. Secret created unsuccessfully"
  fi
}

function displayVault() {
    cat << EOF
Vault available in  http://localhost:8081  with:
Token: ${vaultRootToken}
EOF

}

installVault
initVault
unsealVault
enableVaultK8sAuth
addVaultPermission
addVaultSecret
testSampleSecret
displayVault
```