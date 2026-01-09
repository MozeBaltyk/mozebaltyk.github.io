---
date: 2023-08-01T21:00:00+08:00
title: 🐣 Bash Functions for k8s
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Devops
categories:
  - Docs
tags:
  - Shell
  - Scripting
  - Kubernetes
---

## A list of nice findings for Kubernetes 

* List all images in Helm chart

```bash
images=$(helm template -g $helm |yq -N '..|.image? | select(. == "*" and . != null)'|sort|uniq|grep ":"|egrep -v '*:[[:blank:]]' || echo "")
```

* upload images listed in an Helm chart
```bash
load_helm_images(){
  # look in helm charts
  for helm in $(ls ../../roles/*/files/helm/*.tgz); do
    printf "\e[1;34m[INFO]\e[m Look for images in ${helm}...\n"

    images=$(helm template -g $helm |yq -N '..|.image? | select(. == "*" and . != null)'|sort|uniq|grep ":"|egrep -v '*:[[:blank:]]' || echo "")

    dir=$( dirname $helm | xargs dirname )

    echo "####"

    if [ "$images" != "" ]; then
      printf "\e[1;34m[INFO]\e[m Images found in the helm charts: ${images}\n"
      printf "\e[1;34m[INFO]\e[m Create ${dir}/images images...\n"

      mkdir -p ${dir}/images

      while i= read -r image_name; do
        archive_name=$(basename -a $(awk -F : '{print $1}'<<<${image_name}));
        printf "\e[1;34m[INFO]\e[m Pull images...\n"
        podman pull ${image_name};
        printf "\e[1;34m[INFO]\e[m Push ${image_name} in ${dir}/images/${archive_name}\n"
        podman save ${image_name} --format oci-archive -o ${dir}/images/${archive_name};
      done <<< ${images}
    else
      printf "\e[1;34m[INFO]\e[m No Images found in the helm charts: $helm\n"
    fi
  done
}
```


* Check components version

```bash
function checkComponentsInstall() {
    componentsArray=("kubectl" "helm")
    for i in "${componentsArray[@]}"; do
      command -v "${i}" >/dev/null 2>&1 ||
        { echo "[ERROR] ${i} is required, but it's not installed. Aborting." >&2; exit 1; }
    done
}
```

* Version comparator

```bash
function checkK8sVersion() {
    currentK8sVersion=$(kubectl version --short | grep "Server Version" | awk '{gsub(/v/,$5)}1 {print $3}')
    testVersionComparator 1.20 "$currentK8sVersion" '<'
    if [[ $k8sVersion == "ok" ]]; then
      echo "current kubernetes version is ok"
    else
      minikube start --kubernetes-version=v1.22.4;
    fi
}


# the comparator based on https://stackoverflow.com/a/4025065
versionComparator () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

testVersionComparator () {
    versionComparator $1 $2
    case $? in
        0) op='=';;
        1) op='>';;
        2) op='<';;
    esac
    if [[ $op != "$3" ]]
    then
        echo "Kubernetes test fail: Expected '$3', Actual '$op', Arg1 '$1', Arg2 '$2'"
        k8sVersion="not ok"
    else
        echo "Kubernetes test pass: '$1 $op $2'"
        k8sVersion="ok"
    fi
}
```