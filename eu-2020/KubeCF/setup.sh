#!/usr/bin/env bash

set -euo pipefail

function install_tools() {
  echo
  echo "Installing CF CLI..."
  wget -O cf-cli.tgz "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=6.51.0&source=github-rel" && tar -C "${HOME}/bin" -xf cf-cli.tgz
}

function cluster_zone() {
  if [ "$SEAT" >= 1 && "$SEAT" <= 30 ]; then
    echo "europe-west2-a"
  else
    echo "europe-west2-b"
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
export CLUSTER_NAME="eu-cluster-${SEAT}"
export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"
EOT
}

function main() {
  SEAT="$(echo "${USER}" | tr -d "a-z_")"
  CLUSTER_NAME="eu-cluster-${SEAT}"

  install_tools >&2
  target_cluster >&2
  output_env_vars
}

main
