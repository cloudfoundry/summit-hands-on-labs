## Introduction

In this hands on lab, you will be performing few tasks, some wearing a developer hat and some wearing an operator hat, on `KubeCF`, which is a containerized Cloud Foundry deployment on Kubernetes. `KubeCF` can be seen as a Paas platform for Kubernetes bringing the developer experience of Cloud Foundry.

### Target Audience

This lab is targeted towards the audience who would like to use Cloud Foundry for packaging and deploying applications with Kubernetes as the underlying infrastructure for orchestration of the containers.

### Learning Objectives

You will be performing the following tasks in this lab :-

#### Developer Tasks

* Installation of `KubeCF` platform in Kubernetes.
* Push an application using `cf push`.
* Installation of Minibroker in Kubernetes.
* Create a Redis database instance and connect it to your application.

#### Operator Tasks

* Scale up Diego cells in the `KubeCF` platform.
* Rotate the encryption key of the cloud controller database.

### Prerequisites

Audience must have basic knowledge of Cloud Foundry and Kubernetes.

## Lab

### Install Helm 3
```
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

### Install CF CLI

```
wget https://s3-us-west-1.amazonaws.com/cf-cli-releases/releases/v6.51.0/cf-cli_6.51.0_linux_x86-64.tgz
tar -xvf cf-cli_6.51.0_linux_x86-64.tgz
sudo mv cf /usr/local/bin/
```
```
wget https://s3-us-west-1.amazonaws.com/v7-cf-cli-releases/releases/v7.0.0-beta.30/cf7-cli_7.0.0-beta.30_linux_x86-64.tgz
tar -xvf cf7-cli_7.0.0-beta.30_linux_x86-64.tgz
sudo mv cf7 /usr/local/bin
```

### Using the CLI

You will have access to `kubectl`, `helm`, `cf7` in the terminal.

* `kubectl` is a command line interface for running commands against Kubernetes clusters.
* `helm` is a command line tool for managing Kubernetes applications, used for installing and upgrading KubeCF on Kubernetes cluster.
* `CF CLI` is a command line tool for managing Cloud Foundry applications.

#### Authenticate

To work with Kubernetes you need a valid `KUBECONFIG`. The following commands will acquire a config from Google Cloud.
You will be given a seat number and you should replace the variable *[seat]* with it.

```
seat=[seat]
clustername=na-cluster-"$seat"
```
```
gcloud container clusters get-credentials \
"$clustername" --zone europe-west4-a \
--project summit-labs
```

To check if the connection was successful run

```
kubectl version
helm version
cf version
```

If you can see the versions for both the commands, then you are good to go ahead.

## Developer Hat

### Installing KubeCF

`KubeCF` is already installed for you in the GKE cluster as it takes approximately 15 minutes for the installation. It only takes few commands to install `KubeCF` on any Kubernetes cluster. You need not run the below commands.

* Install cf-operator and Kubecf
```
kubectl create ns cf-operator
helm install cf-operator --namespace cf-operator \
--set "global.operator.watchNamespace=kubecf" \
https://github.com/cloudfoundry-incubator/quarks-operator/releases/download/v4.5.6/cf-operator-4.5.6+0.gffc6f942.tgz 
```
```
helm install kubecf --namespace kubecf \
--set "system_domain= na$seat.kubecf.net" \
--set "features.ingress.enabled=true" \
https://github.com/cloudfoundry-incubator/kubecf/releases/download/v2.2.2/kubecf-v2.2.2.tgz
```

You can find all the configurable values that you can set using `helm set` for `KubeCF` in this [file](https://github.com/cloudfoundry-incubator/kubecf/blob/master/deploy/helm/kubecf/values.yaml).

Wait untill all the KubeCF pods are in running status.

```
watch kubectl get pods -n kubecf
```

#### Troubleshooting

If you want to re-install, uninstall the helm releases, delete the pvc's and retry.

```
helm uninstall kubecf -n kubecf
kubectl delete pvc --all -n kubecf
kubectl delete ns kubecf
helm uninstall cf-operator -n cf-operator
kubectl delete ns cf-operator
```

### Pushing an App

Pushing an app into `KubeCF`, requires a configured `Cloud Foundry CLI`. You shall now configure the CLI with the domain name `"na$seat.kubecf.net"` which points to the installed KubeCF platform.

* Set the KubeCF API url.
```
cf api --skip-ssl-validation http://api.na"$seat".kubecf.net
```
* Login using the user admin, so that you have full access to the `KubeCF` platform.
```
admin_password=$(kubectl get secret \
-n kubecf var-cf-admin-password \
-o jsonpath="{.data.password}" | base64 --decode)
cf login -u admin -p "${admin_password}"
```
* Create an organisation and space where you can push applications.
```
cf create-org demo
cf target -o demo
cf create-space demo
cf target -s demo
```
* Push an application into `KubeCF` platform using the `cf push` command.

```
git clone https://github.com/rohitsakala/cf-redis-example-app
cd cf-redis-example-app
cf push
``` 

In a PaaS platform like `KubeCF`, only the application is managed by the developer, rest all is managed by the Paas platform `KubeCF`.

Check if the app has been successfully deployed.

```
curl http://redis-example-app.na"$seat".kubecf.net
```

So, you have successfully deployed an application into KubeCF platform. Let's connect a database to it now.

#### Troubleshooting

If you want to re-install, delete the app and retry.

```
cf delete redis-example-app
```

### Install Minibroker

Minibroker is an open source service broker based on [Open Service Broker API](https://www.openservicebrokerapi.org/). Using service brokers, cloud foundry apps can connect to external services such as databases, SaaS applications etc. Services deployed in Kubernetes can also be connected using service brokers.

* Install Minibroker using helm.
```
cd ..
kubectl create ns minibroker
helm repo add suse https://kubernetes-charts.suse.com
helm install minibroker --namespace minibroker suse/minibroker \
--set "defaultNamespace=minibroker"
cat minibroker-ingress.yaml | sed "s/replace/'minibroker.na$seat.kubecf.net'/g" \
| kubectl apply -f -
```
* Check the minibroker pod.
```
kubectl get pods -n minibroker
```
* Connect minibroker to `KubeCF` platform.
```
cf create-service-broker minibroker \
username password http://minibroker.na$seat.kubecf.net
```
* List the redis database services and their associated plans the minibroker has access to :- 
```
cf service-access -b minibroker | grep redis
```

#### Troubleshooting

If you want to re-install, uninstall the helm release and re-install.

```
echo y | cf delete-service-broker minibroker 
helm uninstall minibroker -n minibroker
```

### Create a Redis Database Instance

Lets now enable a redis database service in the minibroker, create a security group and create an instance of redis database.

```
cf enable-service-access redis -b minibroker -p 4-0-10
```
```
echo > redis.json '[{ "protocol": "tcp", "destination": "10.0.0.0/8", "ports": "6379", "description": "Allow Redis traffic" }]'
cf create-security-group redis_networking redis.json
cf bind-security-group redis_networking demo demo
```
```
cf create-service redis 4-0-10 redis-example-service
```

Check if the redis master and slave pods are running.
```
watch kubectl get pods --namespace minibroker
```
Check the status of the service creation. Wait until it creation is competed.
```
watch cf service redis-example-service
```

#### Troubleshooting

If you want to re-create, delete the service and retry.

```
cf delete-service redis-example-service
```

### Connect Redis to App

Bind the redis database instace to your pushed application.
```
cf bind-service redis-example-app redis-example-service
```
You need to restage/restart your application for the redis configuration to be pushed into your app environment. Lets do rolling update with zero downtime.
```
cd cf-redis-example-app
cf7 push redis-example-app --strategy rolling
```

When the application is ready, it can be tested by storing a value into the Redis service

```
curl --request GET http://redis-example-app.na$seat.kubecf.net/foo
curl --request PUT http://redis-example-app.na$seat.kubecf.net/foo --data 'data=bar'
curl --request GET http://redis-example-app.na$seat.kubecf.net/foo
```

The first GET will return key not present. After storing a value, it will return bar.

To summarize, you have deployed KubeCF, pushed an application, created a redis database instance using minibroker and connected it to your application.

#### Troubleshooting

If you want to re-bind, unbind the service and retry.

```
cf unbind-service redis-example-app redis-example-service
```

## Operations Hat

### Scale your Diego Cells

There will come a situation in your company, where in, you need to push more apps. Easy !!!! Scale up the diego cells.

* Upgrade kubecf platform, setting the instances for diego-cell to 2.
```
helm upgrade kubecf --namespace kubecf \
--set "sizing.diego_cell.instances=2" \
--set "system_domain=na$seat.kubecf.net" \
--set "features.ingress.enabled=true" \
https://github.com/cloudfoundry-incubator/kubecf/releases/download/v2.2.2/kubecf-v2.2.2.tgz 
```

A new pod `diego-cell-1` should be running :-
```
watch kubectl get pods -n kubecf
```

Now, check if your app still exists.
```
curl --request GET http://redis-example-app.na$seat.kubecf.net/foo
```

### Rotate Cloud Controller encryption key

Lets see another operator task. Suppose you need to rotate your cloud controller database encryption key. CAPI release has a errand job which rotates your database encryption key. QuarksJob is used to run BOSH errand jobs in KubeCF world.

* Check if there is a QuarksJob for rotation
```
kubectl -n kubecf get quarksjobs rotate-cc-database-key
```
* Trigger it now
```
kubectl patch qjob rotate-cc-database-key \
  --namespace kubecf \
  --type merge \
  --patch '{"spec":{"trigger":{"strategy":"now"}}}'
```
* Wait for 1 min and check if the rotation was succesful by checking the logs
```
podName=`kubectl -n kubecf get pod \
-l quarks.cloudfoundry.org/qjob-name=rotate-cc-database-key \
-o jsonpath='{.items[0].metadata.name}'`
kubectl -n kubecf logs $podName rotate-cc-database-key-rotate
```


Congratulations you have successfully completed `Dev and Ops with KubeCF` hands on lab. Your training for developer peace is completed. :wink:


## Beyond the Lab

* KubeCF Docs : https://kubecf.suse.dev/docs/
* Minibroker Project : https://github.com/SUSE/minibroker
* Quarks Project : https://github.com/cloudfoundry-incubator/quarks-operator
