#!/bin/bash

for i in $(seq 12); do
    account=training.hol.$i@cloudfoundry.org
    gcloud --account=${account} \
           --project="hol-basel-project-1" \
           alpha cloud-shell ssh --command="git pull -t origin master && ./bin/nuke" &
done
wait
