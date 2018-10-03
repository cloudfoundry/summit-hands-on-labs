#!/bin/bash

for i in $(seq 12); do
    account=training.hol.$i@cloudfoundry.org
    repo=https://github.com/rkoster/hands-on-labs-student-home
    gcloud --account=${account} \
           --project="hol-basel-project-1" \
           alpha cloud-shell ssh --command="git init && git remote add origin ${repo} || true && git pull -t origin master"
done
wait
