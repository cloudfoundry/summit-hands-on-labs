# Provision PostgreSQL on Kubernetes cluster using Service Fabrik

## Introduction
In this lab paticipants will experience the ease with which a new backing service provisioner can be integrated with [Service Fabrik](https://github.com/cloudfoundry-incubator/service-fabrik-broker). They will learn how to bring in new provisioner to provision a PostgreSQL instance on [shoot cluster](https://kubernetes.io/blog/2018/05/17/gardener/) managed by [Gardener](https://gardener.cloud/).

## Learning Objectives
In this lab participant with learn
1. Ease with which they can bring there own components into Service Fabrik
2. Experience PosgreSQL provisioning on Kubernetes Cluster

## Prerequisites
1. Basic understanding of CF ecosystem for example creating a service instance, binding a service instance etc.
2. Basic understanding of [Service Broker](https://github.com/openservicebrokerapi/servicebroker).

## Lab

## Learning Objectives Review
Now that you have deployed [Service Fabrik](https://github.com/cloudfoundry-incubator/service-fabrik-broker) with provisioner to provision a PostgreSQL instance, you should:
* Understand how to integrate a new provisioner with [Service Fabrik](https://github.com/cloudfoundry-incubator/service-fabrik-broker)
* Don't stop, bring in any service you want

## Beyond the Lab
Write a real provisioner and integrate it with [Service Fabrik](https://github.com/cloudfoundry-incubator/service-fabrik-broker)
* Deploy Service Fabrik on Bosh-Lite: https://github.com/cloudfoundry-incubator/service-fabrik-broker/blob/master/README.md
* Try out existing BOSH and Docker provisioners: https://github.com/cloudfoundry-incubator/service-fabrik-broker/blob/master/README.md#launch-the-managers
* Bring your own provisioner: https://github.com/cloudfoundry-incubator/service-fabrik-broker/blob/master/SF2.0.md 
