#!/bin/bash

for i in $(seq 12); do
    account=training.hol.$i@cloudfoundry.org
    echo "Login to ${account}"
    echo ${account} | pbcopy
    gcloud auth login --account=${account} --quiet
done
wait

config_path=$(gcloud info --format json | jq -r '.config.paths.global_config_dir')
sqlite3 ${config_path}/credentials.db "SELECT value FROM credentials;" ".schema credentials;" ".exit" \
    | jq -c '.id_token | {email: .email, expires: (.exp | todate)}'
