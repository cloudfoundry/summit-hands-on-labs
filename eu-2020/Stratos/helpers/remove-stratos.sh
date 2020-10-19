#!/usr/bin/env bash

sn=my-stratos-namespace
name=my-stratos-console

helm delete $name -n $sn
kubectl delete ns $sn