# Lab Description

With this lab we want to demonstrate the ease with which a broker developer can on-board a new backing service provisioner on [Service Fabrik](https://github.com/cloudfoundry-incubator/service-fabrik-broker). In this lab we intend to show how you can bring in new provisioner to provision a PostgreSQL instance on [shoot cluster](https://kubernetes.io/blog/2018/05/17/gardener/) managed by [Gardener](https://gardener.cloud/).

# Program Description

With this lab we want to demonstrate the ease with which a broker developer can on-board a new backing service provisioner on [Service Fabrik](https://github.com/cloudfoundry-incubator/service-fabrik-broker). In this lab we intend to show how you can bring in new provisioner to provision a PostgreSQL instance on [shoot cluster](https://kubernetes.io/blog/2018/05/17/gardener/) managed by [Gardener](https://gardener.cloud/).

# Environment

Target lab environment would be a separate environment for each participant comprising of the following

1. BOSH-Lite deployed on GCP infrastructure via bbl for each participant
2. CF deployed on Bosh-Lite for each participant
3. Service Fabrik deployed on Bosh-Lite for each participant
4. A pre-provisioned, shared Gardener Shoot Cluster
5. Service Fabrik to have required privileges to create PostgreSQL service on Gardener
6. Student chromebook should be setup with bbl and bbl state repository

# Setup

As described in above section, each Student will get own Bosh-Lite environment with CF and Service Fabrik deployed. To access the Bosh-Lite environment, bbl and bbl state repository should be setup on each Student chromebook.
Open Cloud Shell with below url:

https://console.cloud.google.com/cloudshell/editor?shellonly=true&cloudshell_git_repo=https%3A%2F%2Fgithub.com%2Fcloudfoundry%2Fsummit-hands-on-labs&cloudshell_working_dir=basel-2018%2Fpostgres-on-k8s-with-sf&cloudshell_tutorial=student-template.md


# Issues
Nothing yet.
