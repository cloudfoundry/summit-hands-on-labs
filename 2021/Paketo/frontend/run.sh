#!/bin/bash

set -e
set -u
set -o pipefail

ROOTDIR="$(cd "$(dirname "${0}")" && pwd)"
readonly ROOTDIR

function main() {
  local content
  content="$(cat "${ROOTDIR}/nginx.conf")"
  envsubst '${BACKEND_HOST}' <<<"${content}" > "${ROOTDIR}/nginx.conf"
  exec nginx -c "${ROOTDIR}/nginx.conf"
}

main "${@:-}"
