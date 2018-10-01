#!/bin/bash

[ -z "$CLOUD_SHELL" ] && echo "This script needs to run from Google Cloud Shell" && exit 1;

for i in $(seq 12); do
    gcloud auth login --account=training.hol.$i@cloudfoundry.org --quiet
done
wait

sqlite3 /tmp/*/credentials.db "SELECT value FROM credentials;" ".schema credentials;" ".exit" \
    | jq -c '.id_token | {email: .email, expires: (.exp | todate)}'
