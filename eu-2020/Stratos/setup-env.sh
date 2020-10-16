#!/usr/bin/env bash

set -eo pipefail

function install_tools() {
  echo "Installing Helm..."
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh

  echo "Verifying correct installation of required tools..."
  kubectl version --client=true
  helm version
  echo
}

function cluster_zone() {
  if [[ $((SEAT)) < 50 ]]; then
    echo "europe-west3-a"
  else
    echo "europe-west3-b"
  fi
}

function target_cluster() {
  echo "Targeting cluster ${CLUSTER_NAME}..."
  gcloud container clusters get-credentials "${CLUSTER_NAME}" --zone "$(cluster_zone)" --project summit-labs
  echo
}

function create_kube_token() {
  echo "Creating Kube Service Access Token..."
  
  local NS="kube-system"

  kubectl apply -n $NS -f service-account.yaml
  local SERVICE_USER=stratos

  # Service account should be created - now need to get token
  local SECRET=$(kubectl get -n $NS sa $SERVICE_USER -o json | jq -r '.secrets[0].name')
  KUBE_TOKEN=$(kubectl get -n $NS secret $SECRET -o json | jq -r '.data.token')
  KUBE_TOKEN=$(echo $KUBE_TOKEN | base64 -d -)
}

function main() {
  if [ -z "$1" ] ; then
    SEAT="$(echo "${USER}" | tr -d "a-z_")"
  else
    SEAT=$1
  fi

  CLUSTER_NAME="stratos-${SEAT}"
  echo "Setting up for user '${USER}' at seat '${SEAT}' and cluster name '${CLUSTER_NAME}'"

  PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"

  install_tools
  target_cluster
  create_kube_token

  # KUBE_URL=$(kubectl cluster-info | grep "Kubernetes master" | cut -c 44-)
  KUBE_URL="https://cluster-${SEAT}.lab.stratos.app"

  echo "Set up complete"
  echo "Your Kube Cluster URL is '${KUBE_URL}'"
  echo "Your Kube Cluster Token is '${KUBE_TOKEN}'"
}

main $1
