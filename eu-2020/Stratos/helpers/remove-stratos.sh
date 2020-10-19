#!/usr/bin/env bash

stratos_namespace=my-stratos-namespace
stratos_name=my-stratos-console

wordpress_namespace=my-wordpress-namespace
wordpress_name=my-wordpress

helm delete $stratos_name -n $stratos_namespace
kubectl delete ns $stratos_namespace

helm delete $wordpress_name -n $wordpress_namespace
kubectl delete ns $wordpress_namespace