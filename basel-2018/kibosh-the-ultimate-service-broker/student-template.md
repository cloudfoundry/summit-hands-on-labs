## Introduction
In this lab you will explore Kibosh and learn to deploy Helm Charts as Services on Kubernetes via Kibosh' Open Service Broker API. On demand dedicated services the easy way.  Joining us you will create a rabbit-mq service offering on Kibosh from a base chart and use Kibosh to provision an instance of your rabbit-mq service.


## Learning Objectives
- Understanding the ServiceBroker API.
- Understanding how Kibosh uses HelmCharts
- Learning how to create a service from a helm chart basis (e.g. from https://github.com/helm/charts/tree/master/stable)


## Lets go :)
#### First lets get a container that contains almost everything we need and put it in the background


`docker run -itd nouseforaname/kibosh-lab-cloud-shell`

####  Now we need to go into the container, so let us find out the ID

`export CONTAINER_ID=$(docker ps | tail -1 | awk '{ print $1}')`

#### Copy the base files into the container

`docker cp ../kibosh-the-ultimate-service-broker $CONTAINER_ID:/kibosh-lab`

#### Step into the arena :)
`docker exec -it $CONTAINER_ID /bin/bash`


#### Let us set your name
`export STUDENT_NAME=<your_name>` 

#### This will create your workdir and extract the base files there

`mkdir "/$STUDENT_NAME" && cd "/$STUDENT_NAME" && tar -xzf /kibosh-lab/lab/rabbitmq.tgz && mv rabbitmq "${STUDENT_NAME}_rabbit"`

#### The first step to do is to define our new Service name. The name of the folder that contains your files, needs to match with the charts name param in Chart.yml

`vi ${STUDENT_NAME}_rabbit/Chart.yaml`

#### Now we need to define our plans

`vi ${STUDENT_NAME}_rabbit/plans.yaml`

#### You can use this File as your base

```
- name: "ha"
  description: "High availablity"
  file: "ha.yaml"
- name: "singlenode"
  description: "Single node"
  file: "single.yaml"
```
#### notice that each plan specifies a plan yaml. This is where the actual configuration goes. In our scenario we will just change the amount of nodes deployed


`mkdir -p ${STUDENT_NAME}_rabbit/plans && vi ${STUDENT_NAME}_rabbit/plans/ha.yaml`


```
rmq:
  replicas: 3
```

#### now the singlenode plan

`vi ${STUDENT_NAME}_rabbit/plans/single.yaml`

```
rmq:
  replicas: 1
```
#### what did we change right now? Every Chart comes with a values.yaml. This file contains reasonable defaults for the Chart to work.

`cat ${STUDENT_NAME}_rabbit/values.yaml | awk 'NR >= 12 && NR <= 16'`

#### By specifying plans we can override defaults from the values.yaml. By doing this we build and define how our service instances are provisioned
#### For the rabbitmq chart this is already enough for us to be able create a service instance, let us package our Service Chart

`cd "/${STUDENT_NAME}" && tar -czf "${STUDENT_NAME}_rabbit.tgz" ${STUDENT_NAME}_rabbit`

## Uploading and Managing Service Charts

#### First let us source the ENV Vars provided by the LAB to have EDEN and BAZAAR CLI configured
`source /kibosh-lab/lab/kibosh.env`

#### Now that the CLIs are configured we can get the current catalog
`eden catalog`

#### Upload to the bazaar endpoint
`bazaar -t $BAZAAR_URL -u $BAZAAR_USER -p $BAZAAR_PASSWORD save ./"${STUDENT_NAME}_rabbit.tgz"`
#### Check if succeeded
`bazaar -t $BAZAAR_URL -u $BAZAAR_USER -p $BAZAAR_PASSWORD list`

`eden catalog`

`eden provision -s "${STUDENT_NAME}_rabbit" -p ha`

#### After provisioning is done you can view your Service Instance with
`eden services`

#### Eden will output a service ID that we can use to create a binding
`eden bind -s <service_id_from_previous command>`

#### The Last Command output a JSON with external IPs and port Config. Since our Environment is Loadbalanced, we only need to look for the respective "nodePort" fields, e.g. for the http Endpoint. 

#### Open 35.234.80.160:<your_http_node_port> to access RabbitMqs WebMgmt


## Learning Objectives Review
- Understand the OSB Api
- Understand how Kibosh uses Helm-Charts to implement the OSB Spec
- Understand the workflow to create Kibosh Services from Helm-Charts

## Beyond the Lab

- Check out Helms curated charts repo
`https://github.com/helm/charts/tree/master/stable`

- Cooperate on Kibosh
`https://github.com/cf-platform-eng/kibosh`
