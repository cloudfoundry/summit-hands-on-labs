#!/usr/bin/env bash

set -euo pipefail

function install_tools() {
  echo "Installing Helm..."
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh

  echo "Verifying correct installation of required tools..."
  kubectl version
  helm version
  echo
}

function cluster_zone() {
  if [[ $((SEAT)) < 50 ]]; then
    echo "eu-west-3-a"
  else
    echo "eu-west-3-b"
  fi
}

function target_cluster() {
  echo "Targeting cluster ${CLUSTER_NAME}..."
  gcloud container clusters get-credentials "${CLUSTER_NAME}" --zone "$(cluster_zone)" --project summit-labs
  echo
}

function create_kube_token() {
  # echo "Creating Kube Service Access Token..."#// TODO: fix
  
  local NS="kube-system"

  kubectl apply -n $NS -f service-account.yaml
  local SERVICE_USER=stratos

  # Service account should be created - now need to get token
  local SECRET=$(kubectl get -n $NS sa $SERVICE_USER -o json | jq -r '.secrets[0].name')
  local KUBE_TOKEN=$(kubectl get -n $NS secret $SECRET -o json | jq -r '.data.token')
  local KUBE_TOKEN=$(echo $TOKEN | base64 -d -)

  # Output
  echo "$KUBE_TOKEN" #// TODO: fix
}

function output_env_vars() {
  echo "Generating custom environment settings..." >&2
  cat <<EOT
export SEAT="${SEAT}"
export CLUSTER_NAME="lab-${SEAT}"
export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"
export KUBE_TOKEN="${KUBE_TOKEN}""
EOT
}

function main() {
  SEAT="$(echo "${USER}" | tr -d "a-z_")"
  SEAT=1 // TODO: RC remove
  CLUSTER_NAME="stratos-${SEAT}"

  install_tools >&2
  target_cluster >&2 // TODO: Add back in
  KUBE_TOKEN=$(create_kube_token) // TODO: Add back in
  output_env_vars

  # run export in script
  # run script as `source setup-env.sh`
  # remove redirect from function
}

main
