#! /bin/bash

set -ex

APP_NAME='docs-app'
PREFIX=$(whoami)
MANIFEST_PATH='./manifest.yml'
CONFIG_PATH='config.toml'

# check if cf CLI installed
type -P cf &>/dev/null || { echo "cf CLI not found"; exit 35; }

# check if cf CLI logged in
if cf api | grep -q "api version" ; then
  echo "cf CLI logged in, all OK"
else
  echo "Please log in to CF with cf CLI"
  exit 36
fi
  
#get hugo bin
if [ -d tmp ]  ; then rm -rf tmp ; fi 
mkdir tmp ; cd tmp
wget https://github.com/gohugoio/hugo/releases/download/v0.58.1/hugo_0.58.1_Linux-64bit.tar.gz -O hugo.tar.gz
tar -xf hugo.tar.gz 
cp hugo ../hugo
cd ../
rm -rf tmp

app_domain=$(cf domains | grep -m1 shared | awk '{print $1}')


app_route="${PREFIX}_${APP_NAME}.${app_domain}"

cat << EOF > $MANIFEST_PATH
---
applications:
  - name: 
    routes:
    - route: $app_route 
    buildpacks:
    -  
    path: public
    memory: 100M
EOF

cat << EOF > $CONFIG_PATH
baseURL = "http://$app_route"
languageCode = "en-us"
title = "Troubleshooting chalenge docs"
theme = "hugo-theme-techdoc"
EOF

# run hugo
./hugo
rm hugo
