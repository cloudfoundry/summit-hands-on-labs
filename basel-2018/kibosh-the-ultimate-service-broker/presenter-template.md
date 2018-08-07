# Lab Description

We're demonstrating how to utilize Kibosh to provide on demand services hosted on PKS. Kibosh takes your Helm Charts (Kubernetes Package Manager) and auto implements the service broker API for you to create the service offering you always dreamed of. We go through the steps to setup and deploy Kibosh to be able to create and consume a service offering from Kibosh.  See the [kibosh repository](https://github.com/cf-platform-eng/kibosh) for more information

# Program Description
On demand dedicated Services?
Container Based Service Instances?
Automatically implemented Service Broker APIs?

Say no more and try Kibosh today.


# Environment

  1. shared CF with one Org that holds spaces for participants
  2. Access to a BOSH director to deploy Kibosh
  3. shared large PKS Cluster (~ 10 Workers) to deploy services on

# Setup
1. Setup CF
2. Setup PKS
3. Provision PKS
4. Deploy Kibosh
5. Register Kibosh as a ServiceBroker with CF

# Issues
