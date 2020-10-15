#!/usr/bin/env bash

set -e

sn=stratos

helm delete stratos-console -n $sn
kubectl delete ns $sn