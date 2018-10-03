#!/bin/bash

for i in $(seq 12); do
    account=training.hol.$i@cloudfoundry.org
    echo "Login to ${account}"
    echo ${account} | pbcopy
    gcloud auth login --account=${account} --quiet
done
wait
