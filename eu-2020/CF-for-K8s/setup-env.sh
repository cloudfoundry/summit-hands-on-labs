#!/usr/bin/env bash

set -euo pipefail

function install_tools() {
  echo "Installing Carvel tools..."
  mkdir -p "${HOME}/bin"
  export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"
  wget -O- https://k14s.io/install.sh | K14SIO_INSTALL_BIN_DIR="${HOME}/bin" bash

  echo
  echo "Installing CF CLI..."
  wget -O cf-cli.tgz "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=v7&source=github" && tar -C "${HOME}/bin" -xf cf-cli.tgz

  echo
  echo "Installing BOSH CLI..."
  wget -O "${HOME}/bin/bosh" https://github.com/cloudfoundry/bosh-cli/releases/download/v6.3.0/bosh-cli-6.3.0-linux-amd64 && chmod +x "${HOME}/bin/bosh"

  echo
  if pip3 show yq > /dev/null; then
    echo "Uninstalling old yq..."
    pip3 uninstall yq -y
  fi

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

function cluster_zone() {
  if [[ $((SEAT % 2)) = 0 ]]; then
    echo "us-central1-a"
  else
    echo "us-central1-b"
  fi
}

function target_cluster() {
  echo "Targeting cluster ${CLUSTER_NAME}..."
  gcloud container clusters get-credentials "${CLUSTER_NAME}" --zone "$(cluster_zone)" --project summit-labs
  echo
}

function output_env_vars() {
  echo "Generating custom environment settings..." >&2
  cat <<EOT
export SEAT="${SEAT}"
export CLUSTER_NAME="cf-for-k8s-lab-${SEAT}"
export CF_DOMAIN="${CF_DOMAIN}"
export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"
EOT
}

function main() {
  SEAT="$(echo "${USER}" | tr -d "a-z_")"
  if [[ -z "${SEAT}" ]]; then
    SEAT=1
  fi
  CLUSTER_NAME="cf-for-k8s-lab-${SEAT}"
  CF_DOMAIN="${CLUSTER_NAME}.cf-for-k8s-labs.com"

  install_tools >&2
  target_cluster >&2
  output_env_vars
}

main
