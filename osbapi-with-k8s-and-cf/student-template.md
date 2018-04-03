## Introduction

In this lab, students will write and deploy a very simple Service Broker and then register this Service Broker in Cloud Foundry and Kubernetes. 
They will exercise the service instance lifecycle and bind a service instance to a sample app in both platforms. 

## Learning Objectives
At the end of this lab, students will:

* Know what the Open Service Broker API (OSPABI) is and why it's beneficial.
* Feel comfortably registering a service broker in both Cloud Foundry and Kubernetes
* Understand how to create service instances, see service plans, and other basic operations in both platforms.

## Prerequisites

* Basic familiarity with the terminal/command line

## Lab

Basic flow:
1. Introduction
 - Who we are, what OSBAPI is, what SAPI is
 - Say exactly what we're going to do. (One sentence)
2. Create the service broker
 - Explain basics of what a service broker is.
 - Should have a slide with a basic definition/explanation.
 - Open up the service broker code and catalog (explain services, plans, and instances)
3. Deploy the service broker to your CF space
 - cf push
 - cf apps
4. CF walkthrough
-- Register broker
 - cf create-service-broker <..> --space-scoped
-- List plans
 - cf marketplace (to see your services)
 - cf service-brokers (to see your broker)
-- Create a service instance
 - cf create-service my-service-instance
 - cf service my-service-instance
-- Create a simple app
 - Open up the CF sample app and just show what it's doing.
 - cf push my-app
-- Bind to simple app
 - curl <app-address> 
 - cf bind-service my-app my-service-instance
 - cf service my-service-instance
 - cf restart my-app
 - curl <app-address>
5. K8s walkthrough
-- Register broker
kubectl create -f broker.yaml
-- List plans ?
kubectl get clusterservicebrokers broker-name -o yaml
kubectl get clusterserviceclasses -o=custom-columns=NAME:.metadata.name,EXTERNAL\ NAME:.spec.externalName
kubectl get clusterserviceplans -o=custom-columns=NAME:.metadata.name,EXTERNAL\ NAME:.spec.externalName
-- Create a service instance
kubectl get serviceinstances -n user_ns my-instance -o yaml
-- Create a simple app
- show them the server.js and Dockerfile
- Unknown: push the image? have their username as the image tag
kubectl run my-app --image=hello-node:v1 --port=8080

-- Bind to simple app
1. create the service binding
kubectl create -f service-binding.yml
2. Add secrets to the app
kubectl edit deployment my-app (and add mapping from secret to env vars) 


Problems with k8s broker:
k8s user Auth not working (rbac)
check that names are valid now
see if it's a problem that basic auth wasn't provided to broker
Later:
(later figure out how to trust the cluster ca)

## Learning Objectives Review

TODO

## Beyond the Lab

Write a real service broker:
* (Link to OSBAPI spec)
* (Link to On-Demand broker)
* (Link to SUSE universal service broker)

Go further with CF:
* (bosh-lite)
* (Something here)

Go further with K8s:
* (Minicube)
* (Something here)
