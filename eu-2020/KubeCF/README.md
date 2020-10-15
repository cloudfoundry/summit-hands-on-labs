
## Introduction

In this hands on lab you will perform several tasks, using `KubeCF`, which is a containerized Cloud Foundry deployment on Kubernetes. `KubeCF` brings the developer experience of Cloud Foundry to Kubernetes in a production-ready environment. This time `KubeCF` is concentrated on `Eirni` features as `Erini` is now production ready in CAP v2.1.

### Target Audience

This lab is targeted towards an audience who would like to use Cloud Foundry for packaging and deploying applications with Kubernetes as the underlying infrastructure for container orchestration.

### Learning Objectives

You will be performing the following tasks in this lab :-

#### Tasks

* Push an application using `cf push` with `eirini` enabled instead of diego.
* Play around with `Eirni` and its extensions
    * SSH 
    * Persi
    * Logging
* Build your own EiriniX extension and deploy it.

### Prerequisites

Audience must have basic knowledge of Cloud Foundry and Kubernetes.

## Setup Environment

Let's set up your environment by running the following command in your console. 

    eval "$(./setup.sh)"

#### What it's doing

* The script will install cf-cli.
* The script also setups up your `kubeconfig` by connecting to an existing k8s cluster.
* Exports environment variables such as `$SEAT` and `$CLUSTER_NAME`.

### Verify CLIs exists

Running the following command will print versions for the CLI. 

    cf version

### Verify `KuebCF` pods

Run the following command to list the `Cloud Foundry` component pods deployed in `kubecf` namespace.

    kubectl get pods -n kubecf

* Your output should display all component pods with `Running` status.
* `KubeCF` is already installed for you using `helm`. 
* In case, you are interested to know how it is installed, you can checkout the steps from
[Installation Instructions](https://kubecf.io/docs/deployment/kubernetes-deploy/).

### Pushing an App

Pushing an app into `KubeCF`, requires a configured `Cloud Foundry CLI`. You shall now configure the CLI with the domain name `"eu$SEAT.kubecf.net"` which points to the installed KubeCF platform.

* Set the KubeCF API url.

        cf api --skip-ssl-validation \
        http://api.na"$SEAT".kubecf.net

* Login using the user admin, so that you have full access to the `KubeCF` platform.

        admin_password=$(kubectl get secret \
        -n kubecf var-cf-admin-password \
        -o jsonpath="{.data.password}" | base64 --decode)
        cf login -u admin -p "${admin_password}"

* Create an organisation and space where you can push applications.

        cf create-org demo
        cf target -o demo
        cf create-space demo
        cf target -s demo

* Push an application into `KubeCF` platform using the `cf push` command.

        git clone https://github.com/rohitsakala/cf-redis-example-app
        cd cf-redis-example-app
        cf push
 
 * Checkout if the app has been successfully deployed.
        
        kubectl get pods -n eirini

* Go to url in the browser. Make sure to replace the `$seat` variable.
```
http://redis-example-app.na$seat.kubecf.net
```

OR

* Curl the url.

        curl http://redis-example-app.na$seat.kubecf.net


So, you have successfully deployed an application into KubeCF platform.

#### Troubleshooting

If you want to re-install, delete the app and retry the section.

    cf delete redis-example-app


## Developer Hat

### Install Minibroker

Minibroker is an open source service broker based on [Open Service Broker API](https://www.openservicebrokerapi.org/). Using service brokers, Cloud Foundry apps can connect to external services such as databases, SaaS applications etc. Services deployed in Kubernetes can also be connected using service brokers.

* Install Minibroker using helm.

* Create minibroker namespace.
  
        cd ..
        kubectl create ns minibroker

* Add minibroker helm rpo

        helm repo add suse https://kubernetes-charts.suse.com
        helm install minibroker --namespace minibroker suse/minibroker \
        --set "defaultNamespace=minibroker"
        cat minibroker-ingress.yaml | sed "s/replace/'minibroker.na$seat.kubecf.net'/g" \
        | kubectl apply -f -


* Check if the minibroker pod is running.

        watch kubectl get pods -n minibroker
        
Press `Ctrl+C` to exit.

* Connect minibroker to `KubeCF` platform.


        cf create-service-broker minibroker \
        user123 password http://minibroker.na$seat.kubecf.net

* List the redis database services and their associated plans the minibroker has access to :- 


        cf service-access -b minibroker | grep redis

* Lets choose a plan and create one in the next steps.

#### Troubleshooting

If you want to re-install, uninstall the helm release and re-install.


        echo y | cf delete-service-broker minibroker 
        helm uninstall minibroker -n minibroker


### Create a Redis Database Instance

Lets now enable a redis database service in the minibroker, create a security group, and create an instance of redis database.

* Enable redis service.

        cf enable-service-access redis -b minibroker -p 4-0-10

* Create & bind security group

        echo > redis.json '[{ "protocol": "tcp", "destination": "10.0.0.0/8", "ports": "6379", "description": "Allow Redis traffic" }]'
        cf create-security-group redis_networking redis.json        
        cf bind-security-group redis_networking demo demo

* Create a redis plan service.

        cf create-service redis 4-0-10 redis-example-service


Check if the redis master and slave pods are running.


        watch kubectl get pods --namespace minibroker

Press `Ctrl+C` to exit.

Check the status of the service creation. Wait until the creation is competed.


        watch cf service redis-example-service

Press `Ctrl+C` to exit.

#### Troubleshooting

If you want to re-create, delete the service and retry.


        cf delete-service redis-example-service


## Developer Hat

### Connect Redis to App

Bind the redis database instace to your pushed application.

    cf bind-service redis-example-app redis-example-service

You need to restage/restart your application for the redis configuration to be pushed into your app environment. Lets do rolling update with zero downtime.

    cd cf-redis-example-app
    cf7 push redis-example-app --strategy rolling


When the application is ready, it can be tested by storing a value into the Redis database.

* The first curl `GET` will return `key not present`, since we did not store any value for the key `foo`.

        curl --request GET http://redis-example-app.na$seat.kubecf.net/foo

* The second curl `PUT` will return `success`, since we stored the value `bar` for the key `foo`.

        curl --request PUT http://redis-example-app.na$seat.kubecf.net/foo --data 'data=bar'

* The third curl `GET` will return `bar`, since we stored the value of the key `foo` as `bar` in the previous curl.

        curl --request GET http://redis-example-app.na$seat.kubecf.net/foo


To summarize, you have deployed KubeCF, pushed an application, created a redis database instance using minibroker and connected it to your application.

#### Troubleshooting

If you want to re-bind, unbind the service and retry the above commands.


    cf unbind-service redis-example-app redis-example-service


## Operations Hat

### Scale your Diego Cells

There will come a situation in your company in which you need to push more apps. Easy !!!! Scale up the diego cells.

* Upgrade kubecf platform by setting the instances for diego-cell pod to 2. The value can be changed using `--set` argument of helm. We need to set `sizing.diego_cell.instances` to 2.

        helm upgrade kubecf --namespace kubecf \
        --set "sizing.diego_cell.instances=2" \
        --set "system_domain=na$seat.kubecf.net" \
        --set "features.ingress.enabled=true" \
        https://github.com/cloudfoundry-incubator/kubecf/releases/download/v2.2.2/kubecf-v2.2.2.tgz 


Note: A list of configurable values can be found at [values](https://github.com/cloudfoundry-incubator/kubecf/blob/master/deploy/helm/kubecf/values.yaml
).

A new pod `diego-cell-1` should be running :-

    watch kubectl get pods -n kubecf

Note: This will take 7 minutes. So, you can take a break.

Press `Ctrl+C` to exit.

Now, check if your app still exists.
* Go to url in the browser. Make sure to replace the `$seat` variable.
```console
http://redis-example-app.na$seat.kubecf.net/foo
```

OR

* Curl the url.

        curl http://redis-example-app.na$seat.kubecf.net/foo


## Operations Hat

### Rotate Cloud Controller encryption key

Lets perform another operator task. Suppose you need to rotate your cloud controller database encryption key. CAPI release has an errand job which rotates your database encryption key. QuarksJob is used to run BOSH errand jobs in KubeCF world.

* Check if there is a QuarksJob for rotation

        kubectl -n kubecf get quarksjobs rotate-cc-database-key

* Trigger it now

        kubectl patch qjob rotate-cc-database-key \
        --namespace kubecf \
        --type merge \
        --patch '{"spec":{"trigger":{"strategy":"now"}}}'

* Wait for few seconds and check if the rotation was succesful by checking the logs

```
podName=`kubectl -n kubecf get pod -l quarks.cloudfoundry.org/qjob-name=rotate-cc-database-key -o jsonpath='{.items[0].metadata.name}'`
kubectl -n kubecf logs $podName rotate-cc-database-key-rotate | grep "Done rotating encryption key for class"
```

Congratulations, you have successfully completed `Dev and Ops with KubeCF` hands on lab. Your training for developer peace is completed. :wink:


## Beyond the Lab

* KubeCF Docs : https://kubecf.suse.dev/docs/
* Minibroker Project : https://github.com/SUSE/minibroker
* Quarks Project : https://github.com/cloudfoundry-incubator/quarks-operator
