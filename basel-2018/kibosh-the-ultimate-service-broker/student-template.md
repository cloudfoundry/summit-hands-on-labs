## Introduction
In this lab you will explore Kibosh and learn to deploy Helm Charts as Services on Kubernetes via Kibosh' Open Service Broker API. On demand dedicated services the easy way.  Joining us you will create a rabbit-mq service offering on Kibosh from a base chart and use Kibosh to provision an instance of your rabbit-mq service.


## Learning Objectives
- Understanding the ServiceBroker API.
- Understanding how Kibosh uses HelmCharts
- Learning how to create a service from a helm chart basis (e.g. from https://github.com/helm/charts/tree/master/stable)


## Prerequisites
- Eden CLI or cURL for requests against Kibosh API (https://github.com/starkandwayne/eden)
- kubectl for running commands against Kubernetes 
- bazaar cli for uploading helm charts (https://github.com/cf-platform-eng/kibosh/releases)
- git for repo access
- rabbitmqctl for testing created rabbit service (https://www.rabbitmq.com/man/rabbitmqctl.8.html)
- jq for parsing JSON
###### __-- OR --__
- *I have a docker container containing all required clis and it can also run kibosh that I'm using for my test pipeline.. If internet access is fast enough, everyone can pull & start the docker container and run her/his own instance against the shared KubeCluster. Then, the only requirement would be to be able to run a local docker image..*
  
## Lab

- Presenters deploy Shared Kubernetes Cluster that runs KIBOSH

- Fire Up your shell :)

- `git clone https://github.com/cloudfoundry/summit-hands-on-labs`

- `cd summit-hands-on-labs/basel-2018/kibosh-the-ultimate-service-broker/ && source lab/kibosh.env `

- `mkdir workdir`

- `cp lab/rabbitmq.tgz workdir/`

- `cd workdir && tar -xzf rabbitmq.tgz`

- `vi rabbitmq/plans.yml`

```
- name: "ha"
  description: "High availablity plan for rmq-dell"
  file: "ha.yaml"
- name: "singlenode"
  description: "Single node plan for rmq-dell"
  file: "single.yaml"
```

- `mkdir -p rabbitmq/plans && vi rabbitmq/plans/ha.yaml`
```
rmq:
  replicas: 3
```
- `vi rabbitmq/plans/single.yaml`
```
rmq:
  replicas: 1
```
- `cat rabbitmq/values.yaml | awk 'NR >= 12 && NR <= 16'`

- `cp -r rabbitmq rabbitmq-<student-name> && tar -czf rabbitmq-service.tgz rabbitmq-<student-name>`
- `eden catalog`
- `bazaar -t $BAZAAR_PREFIX$BAZAAR_FQDN:$BAZAAR_PORT -u $BAZAAR_USER -p $BAZAAR_PASSWORD save rabbitmq-service.tgz`
- `bazaar -t $BAZAAR_PREFIX$BAZAAR_FQDN:$BAZAAR_PORT -u $BAZAAR_USER -p $BAZAAR_PASSWORD list`
- `eden catalog`
- `eden provision -s rabbitmq-<student-name> -p ha`
- `eden bind -s <service_id_from_previous command>`
- **do something with rabbit** 

## Learning Objectives Review
- Understand the OSB Api
- Understand how Kibosh uses Helm-Charts to implement the OSB Spec
- Understand the workflow to create Kibosh Services from Helm-Charts

## Beyond the Lab

- Check out Helms curated charts repo
`https://github.com/helm/charts/tree/master/stable`

- Cooperate on Kibosh
`https://github.com/cf-platform-eng/kibosh`

