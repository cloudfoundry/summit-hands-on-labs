#!/bin/bash

for i in $(seq 12); do
    gcloud auth login --account=training.hol.$i@cloudfoundry.org --quiet
done
wait

sqlite3 /tmp/*/credentials.db "SELECT value FROM credentials;" ".schema credentials;" ".exit" \
    | jq -c '.id_token | {email: .email, expires: (.exp | todate)}'
