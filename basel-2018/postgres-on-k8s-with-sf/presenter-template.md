# Lab Description

With this lab we want to demonstrate the ease with which a broker developer can on-board a new backing service provisioner on [Service Fabrik](https://github.com/cloudfoundry-incubator/service-fabrik-broker). In this lab we intend to provide a ready-to-use implementation of backing service provisioner which helps to provision a PostgreSQL instance on [shoot cluster](https://kubernetes.io/blog/2018/05/17/gardener/) managed by [Gardener](https://gardener.cloud/)

# Program Description

Another lab description for publishing in the CF Summit program.

# Environment

Target lab environment would be a separate environment for each participant comprising of the following

1. BOSH-Lite deployed on GCP for each participant
2. Each BOSH-Lite will have Service Fabrik deployed on it
3. A pre-provisioned Gardener Shoot Cluster
4. Service Fabrik to have required privileges to create PostgreSQL service on Gardener
5. A GitHub repo to host the code for K8S provisioner which the participants can pull from the repo into there Service Fabrik instance

# Setup

This section describes any particular setup issues that need to be done
before presenting your lab.

# Issues
