#!/bin/bash

set -e
export BBL_ENV_NAME=basel-summit-kibosh-lab
export TF_VAR_env_name=$BBL_ENV_NAME
export BBL_IAAS=gcp


# GET BUCC AND CFCR DEPLOYMENT
git submodule update --init

if [ ! -d terraform ]; then
  mkdir terraform
fi

# GET SOME BUCC OVERRIDES GOING, THX RAMON
ln -s -f bucc/bbl/*-director-override.sh .
ln -sr -f bucc/bbl/terraform/$BBL_IAAS/* terraform/

# Add Kibosh extra TF
ln -sr -f kibosh/kibosh-tf-override.tf terraform/

# CHECK FOR BBL, DOWNLOAD IF NECESSARY
if [ -n "$(command -v bbl)" ]; then
  echo "found bbl, continuing"
else
   echo "installing bbl into ./bin/"
   mkdir "$PWD/bin"
    wget "https://github.com/cloudfoundry/bosh-bootloader/releases/download/v6.10.0/bbl-v6.10.0_linux_x86-64" -o "$PWD/bin/bbl"
   chmod +x "$PWD/bin/bbl"
   export PATH=$PATH:$PWD/bin
fi

# CHECK FOR CONFIG EXIT IF GCP DATA IS NOT PROVIDED
if [ -z "$GCP_JSON" ]; then
  echo "please provide gcp key json in VAR GCP_JSON"
  exit 1
elif [ -z "$GCP_REGION" ]; then
  echo "please provide gcp region in VAR GCP_REGION"
  exit 1
else
  echo "$GCP_JSON" > gcp.json
fi

# BBL BUCC UP
if [ -f bbl-state.json ]; then
  bbl up --lb-type concourse --gcp-service-account-key gcp.json --debug
else
  bbl up --lb-type concourse --gcp-service-account-key gcp.json --gcp-region "$GCP_REGION" --debug
fi
# BOSH CLI CONFIG
eval "$(bbl print-env)"
eval "$(bucc/bin/bucc env)"
MASTER_LB_IP="$(bbl outputs | grep kube_master_tcp_lb_ip  | sed 's/kube_master_tcp_lb_ip: //g')"
WORKER_LB_IP="$(bbl outputs | grep kube_worker_tcp_lb_ip  | sed 's/kube_worker_tcp_lb_ip: //g')"
BOSH_NAME="$(bosh env --json | jq '.Tables[0].Rows[0].name' -r)"
# WE MIGHT NEED A STEMCELL AND A RELEASE
bosh us --sha1 61eb67dcebc84d4fa818708f79c1e37d811c99e9 "https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-xenial-go_agent?v=97.17"
bosh ur "https://github.com/cloudfoundry-incubator/kubo-release/releases/download/v0.21.0/kubo-release-0.21.0.tgz"
bosh -n ucc <( bosh int <(bosh cc) -o kibosh/kubo-ops/cloud-config-lb-extension.yml -l kibosh/vars.yml)
bosh -d cfcr -n \
  deploy <( bosh int kubo-deployment/manifests/cfcr.yml -o kibosh/kubo-ops/add-lb-extension-worker.yml -o kibosh/kubo-ops/add-addon-spec.yml -l <(bosh int kibosh/kibosh-spec.yml  -l kibosh/vars.yml) -l kibosh/vars.yml ) \
  -o kubo-deployment/manifests/ops-files/use-runtime-config-bosh-dns.yml \
  -o kubo-deployment/manifests/ops-files/add-hostname-to-master-certificate.yml \
  -v api-hostname="$MASTER_LB_IP"

bosh -d cfcr run-errand apply-addons -n

bucc/bin/bucc credhub

pushd kubo-deployment
  ./bin/set_kubeconfig "$BOSH_NAME/cfcr" "https://$MASTER_LB_IP:8443"
popd 


export KIBOSH_USER=$(bosh int kibosh/vars.yml --path /kibosh-user)
export KIBOSH_PW=$(bosh int kibosh/vars.yml --path /kibosh-pw)
export KIBOSH_PORT=$(kubectl -n kube-system get service/kibosh-np -o json | jq .spec.ports[0].nodePort)
export KIBOSH_URL="http://$WORKER_LB_IP:$KIBOSH_PORT"


export BAZAAR_USER=$(bosh int kibosh/vars.yml --path /bazaar-user)
export BAZAAR_PW=$(bosh int kibosh/vars.yml --path /bazaar-pw)
export BAZAAR_PORT=$(kubectl -n kube-system get service/kibosh-bazaar-np -o json | jq .spec.ports[0].nodePort)
export BAZAAR_URL="http://$WORKER_LB_IP:$BAZAAR_PORT"

echo "#KIBOSH CONFIG FOR STUDENTS" > ./kibosh.env
env | grep "KIBOSH_" >> ./kibosh.env


echo "#BAZAAR CONFIG FOR STUDENTS" >> ./kibosh.env
env | grep "BAZAAR_" >> ./kibosh.env

export KUBECTL_KONTEXT_NAME="$(kubectl config current-context)"
export KUBECTL_KONTEXT_CONF="$(kubectl config view $KUBECTL_CONTEXT_NAME)"

echo "#KUBECTL CONFIG FOR STUDENTS" >> ./kibosh.env
echo "KUBECTL_KONTEXT_NAME=$KUBECTL_KONTEXT_NAME" >> ./kibosh.env
echo "KUBECTL_KONTEXT_CONF=\"$KUBECTL_KONTEXT_CONF\"" >> ./kibosh.env
echo "---------------------PROVIDE TO STUDENTS START---------------------"
cat ./kibosh.env
echo "---------------------PROVIDE TO STUDENTS END-----------------------"
