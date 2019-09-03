#!/bin/bash
export SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );

set -e
rm -fv "${HOME}/gopath/bin/cf"
rm -fv "${HOME}/cf.tgz"
mkdir -pv "${HOME}/gopath/bin"
wget --output-document="${HOME}/cf.tgz" 'https://cli.run.pivotal.io/stable?release=linux64-binary&source=github'
tar -xzf "${HOME}/cf.tgz" -C "${HOME}/gopath/bin/"
chmod a+x "${HOME}/gopath/bin/cf"
cf --version


source ${SCRIPT_DIR}/scripts/wget_plugin_mbt.sh
source ${SCRIPT_DIR}/scripts/login.sh
