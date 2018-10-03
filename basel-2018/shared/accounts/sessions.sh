#!/bin/bash

config_path=$(gcloud info --format json | jq -r '.config.paths.global_config_dir')
sqlite3 ${config_path}/credentials.db "SELECT value FROM credentials;" ".schema credentials;" ".exit" \
    | jq -c '.id_token | {email: .email, expires: (.exp | todate)}'
