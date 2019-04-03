#!/bin/bash
cf install-plugin "https://github.com/cloudfoundry-incubator/multiapps-cli-plugin/releases/download/v2.0.13/mta_plugin_linux_amd64" -f
cf plugins
wget --output-document="${HOME}/mbt.tgz" 'https://github.com/SAP/cloud-mta-build-tool/releases/download/v0.2.2/cloud-mta-build-tool_0.2.2_Linux_amd64.tar.gz'
mkdir -p "${HOME}/gopath/bin/"
tar -xzf "${HOME}/mbt.tgz" -C "${HOME}/gopath/bin/"
chmod a+x "${HOME}/gopath/bin/mbt"
mbt -v
