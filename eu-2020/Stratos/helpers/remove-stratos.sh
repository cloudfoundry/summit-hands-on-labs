#!/usr/bin/env bash

set -e

helm delete stratos-console -n $sn
kubectl delete ns $sn