#!/bin/bash

config_path=$(gcloud info --format json | jq -r '.config.paths.global_config_dir')
sqlite3 ${config_path}/credentials.db ".schema credentials" ".mode insert credentials" "SELECT * FROM credentials WHERE account_id LIKE 'training.hol%';" ".exit" | pbcopy
