#!/usr/bin/env bash

set -euo pipefail

function install_tools() {
  echo "Installing K14s..."
  mkdir -p "${HOME}/bin"
  export PATH="${HOME}/bin:${PATH}"
  wget -O- https://k14s.io/install.sh | K14SIO_INSTALL_BIN_DIR=${HOME}/bin bash

  echo
  echo "Installing CF CLI..."
  wget -O cf-cli.tgz "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=6.51.0&source=github-rel" && tar -C bin -xf cf-cli.tgz

  echo
  echo "Installing BOSH CLI..."
  wget -O bin/bosh https://github.com/cloudfoundry/bosh-cli/releases/download/v6.3.0/bosh-cli-6.3.0-linux-amd64 && chmod +x bin/bosh

  echo
  echo "Installing yq..."
  pip3 install yq --user

  echo "Verifying correct installation of required tools..."
  ytt version
  kapp version
  cf --version
  bosh --version
  yq --version
  echo
}

function target_cluster() {
  # TODO: Add a helper function to select the correct zone in the case that we can't get the quota for us-central1 increased.
  echo "Targetting cluster ${CLUSTER_NAME}..."
  gcloud container clusters get-credentials "${CLUSTER_NAME}" --zone us-central1-a --project summit-labs
  echo
}

function output_env_vars() {
  echo "Generating custom environment settings..." >&2
  cat <<EOT
export SEAT="${SEAT}"
export CLUSTER_NAME="lab-${SEAT}"
export CF_DOMAIN="${CF_DOMAIN}"
export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"
EOT
}

function main() {
  SEAT="$(echo "${USER}" | tr -d "a-z_")"
  CLUSTER_NAME="lab-${SEAT}"
  CF_DOMAIN="${CLUSTER_NAME}.cf-for-k8s-labs.com"

  install_tools >&2
  target_cluster >&2
  output_env_vars
}

main
