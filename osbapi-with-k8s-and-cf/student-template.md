## Introduction

In this lab, students will deploy a very simple Service Broker and then register this Service Broker in Cloud Foundry and Kubernetes.
They will exercise the service instance life cycle and bind a service instance to a sample application in both platforms.

## Learning Objectives

At the end of this lab, students will:

* Know what the Open Service Broker API (OSPABI) is and why it's beneficial.
* Feel comfortable registering a service broker in both Cloud Foundry and Kubernetes
* Understand how to create service instances, see service plans, and other basic operations in both platforms.

## Prerequisites

* Basic familiarity with the terminal/command line
* Able to use basic features of a terminal text editor vim/emacs/nano

## Lab

For this lab, we will be working on a virtual machine that has been pre-provisioned with all the tools we will need. Start by opening a terminal. If you're on a Chromebook you can use the short cut `ctrl-alt-t` to open a terminal. Then open an ssh connection to our virtual machine.

```
ssh <user_name>@jump.sapi.cf-app.com
```

Welcome!

Explore your home directory, if you run the command `ls` you should see a directory
structure that looks little bit like this:

```
ls
cf  k8s  snap
```

These folders contain resources that will be used through out the lab.

At some points in the lab you will need to edit some text files via the command line. We have provisioned our machine with vim, emacs and nano. If you are not familiar with command line editing, we recommend using nano. In our examples we will be using vim, but anywhere that you see vim, feel free to substitute it for emacs or nano. 

### Deploy the Service Broker

TODO: Get an OSBAPI approved definition of a 'service'
A Service is a <???>. Typical examples of services are databases and messaging queues, but can also include anything that fits within the contract defined by the Open Service Broker API.
A Service Broker is an HTTP server which coordinates the service lifecycle between a platform (e.g., Cloud Foundry or Kubernetes) and services. The basic operations that a service broker supports are:
1. Provision a new service instance (for example, provision a new MySQL cluster)
1. Bind to a service instance (for example, provide a set of credentials to access that cluster)
1. Unbind (e.g., revoke the credentials)
1. Deprovision (e.g., destroy the cluster)

Each of these operations is provided via an HTTP endpoint on the service broker.

Another responsibility of a Service Broker, is that they must advertise available
Services and Service Plans. This is done by exposing a catalog endpoint, which
responds with descriptions of the Services and Plans in JSON format.

We are providing a very simple Service Broker for use in this lab. To see the catalog of this simple Service Broker, run the following:

```
less cf/service-broker/catalog.json
```

You should be able to see a fake MySQL service, with two plans, as well as a fake redis service, also with two plans.
When you are done viewing the service broker code, press `q` to exit less.

Open up the Service Broker code for editing by running

```
vim cf/service-broker/server.js
```

(remember that emacs and nano are also available if you feel more comfortable with them.)

As you can see at the top, the `/v2/catalog` endpoint exposes the catalog you saw previously.

Below the catalog endpoint you should see some endpoints to do with creating and deleting service instances, and creating and deleting service bindings. Most of these endpoints are no-op dummy endpoints, just to satisfy the Open Service Broker API ("OSBAPI"), but take a closer look at the PUT to `/v2/service_instance/<guid>/service_bindings/<guid>` endpoint. This endpoint provides credentials to access the service instance, and we've provided a sample username and password. Change the username and password values to be anything you want. You'll see this show up later in the lab when we bind to a service instance. 

Now we're going to deploy this service broker so that it can be accessed from both CF and Kubernetes.

Cloud Foundry provides an opinionated and streamlined experience for running an application on the cloud. Remember the haiku?

"Here is my source code,
run it on the cloud for me,
I do not care how."

We will use cloud foundry to create a service broker that is running in the cloud!

Change directory into the cf/service-broker directory

```
cd ~/cf/service-broker
```

Push the service broker application to Cloud Foundry

```
cf push
```

This will take a minute or so.

You can verify that your service broker is up by running

```
curl http://<broker-url>/v2/catalog
```

(You can see the broker URL in the output of `cf push`)

Congratulations you have deployed a service broker! You Rock!

From here you can start the Cloud Foundry track, or the Kubernetes track. It's recommended to start with the Cloud Foundry
track if you are not already familiar with services in Cloud Foundry. Otherwise, feel free to jump directly to the Kubernetes track.

### Cloud Foundry track

#### Register the Service Broker

Now that we have deployed our service broker, we need to register the broker in Cloud Foundry. This will enable Cloud Foundry users to interact with the services provided by your broker. Let's begin by registering the service broker!

```
cf create-service-broker <broker-name> <username> <password> https://<broker_url> --space-scoped
```

- <broker-name> is a unique identifier for this broker across the entire Cloud Foundry instance. We recommend that you choose a broker-name that includes your username.
- The <username> and <password> fields can be anything. Usually Service Brokers require at least Basic Authentication. Our service broker doesn't require any authentication (which is a terrible idea for any real broker), but Cloud Foundry needs some values to send to the broker.
- <broker_url> must be the url of the Service Broker including the protocol. This is the same value you used when curling the broker earlier. If you don't remember the URL, you can retrieve this by running `cf apps`.
- The `--space-scoped` flag is required for this lab. By default, service brokers are registered across the entire Cloud Foundry instance, which requires admin privileges. Since the lab users accounts are not admins, you will create a service broker that only you can see and use.

#### Viewing the Services and Service Plans

To view the services in the marketplace, enter

```
cf marketplace
```

You should see something similar to this

```
cf marketplace
Getting services from marketplace in org system / space root as admin...
OK

service                plans                              description
fake-mysql-<you>   mysql-top-tier, mysql-free         A fake non-operational mysql service
fake-redis-<you>   redis-small-mem, redis-large-mem   The best fake redis
```

The marketplace gives a description of each service, and tells us what plans are available for each service. This comes directly from the catalog endpoint of the service broker.

#### Create A Service Instance

Great! We are now in a position where we can ask the service broker to create an instance of one of its services. To do this we need to tell it which service we want, and which plan we want. We will also have to provide a name, which will be used to identify our instance.

```
cf create-service <service-name> <service-plan> <instance-name>
```
- <service-name> is the name of one of the services you saw from running `cf marketplace`. Pick either one.
- <service-plan> is the name of a plan in the service you picked (also visible in `cf marketplace`).
- <instance-name> can be anything you want. You will need to refer back to this name later, so you may want it to be short.

What's happening under the hood here:
- We asked Cloud Foundry to create a service instance.
- Cloud Foundry has sent a request to the `PUT /v2/service_instance` endpoint of the Broker
- Our dummy broker responds with a 200 OK, but doesn't actually do anything.
- Cloud Foundry internally creates a record of this service instance, which you can refer to via the name you gave it.

For details about your service instance, run:

```
cf service <instance-name>
```

#### Create a simple app

So far we have used our Service Broker to provision a service instance. Now, we want to hook up an application to use this service instance. To do that we are going to create a binding. But before we do that we need to have an application to bind the service to!

We have provided a very simple app for demonstration purposes. You can view the app code by entering

```
less ~/cf/simple-app/server.js
```

This app checks the value of the `VCAP_SERVICES` environment variable. This is a special environment variable injected into the app's container which provides credentials and other access information for any services bound to this app.
When no service is bound to this app, `VCAP_SERVICES` will be empty, and the app will print "No services instances are bound to this app". When a service instance is bound to this app, it will print the username and password present in the binding.

If you like, feel free to customize the messages returned by this app.

Let's push the app to the cloud!

```
cd ~/cf/simple-app && cf push
```

Once the app has been deployed, let's `curl` it to check its current state:

```
curl http://<app-route>
```

where <app-route> is the route returned at the end of the `cf push` command.

You should get the following response from `curl`:

```
No service instances are bound to this app.
```

So we have our app running on the cloud, great! Now we can explore binding a service instance to our application using our Service Broker.

#### Create a Service Binding

Let's ask Cloud Foundry to create a binding between our service instance and our application. 

```
cf bind-service <app-name> <instance-name>
```

- <app-name> is the name of your app. You should be able to find it by running `cf apps`
- <instance-name> is the name of the service instance you created earlier.

After we make this request there are various things that happen behind the scenes. Firstly Cloud Foundry sends a request to the service broker to create a service binding. The Service Broker must respond with some credentials in JSON format. Cloud Foundry takes these credentials and delivers them to our application via the `VCAP_SERVICES` environment variable.

If we restage our application now, we will see the environment variable changes take effect. 

```
cf restage <app-name>
curl http://<app-route>
```

You should now get the following output:

```
Credentials available: username is 'admin' and password is 'passw0rd'
```

(The exact credentials may be different if you changed the values in the service broker code.)

Congratulations! You have finished the Cloud Foundry track. If you like, move onto the Kuberenetes Track.

### Kubernetes Track

Before you start the Kubernetes track you should have already deployed a Service Broker. If you have not already done so please start here.

#### Register the Service Broker
Now that you have deployed a Service Broker, we need to register the broker in Kubernetes! This will allow Kubernetes users to interact with with services provided by your broker. 

We will create the service broker using the `kubectl` Command Line Interface, which has been pre installed on our machine.

We will ask Kubernetes to create our Service broker based on a small manifest. Let's take a look at this manifest

```
vim k8s/resources/broker.yml
```

Here we provide some instructions to Kubernetes regarding the type of resource we want
to create. The important fields are:
- `kind: ClusterServiceBroker` This tells Kuberenetes we want to create a Service Broker
- `metadata.name:` A unique name to identify the Broker, we have auto generated this for you
- `spec.url:` This is the location of the Service Broker. You will need to edit this with the url of our service broker

We can get the url of our broker by running 

```
$: cf apps
Getting apps in org lab / space hol as admin...
OK

name                   requested state   instances   memory   disk   urls
hol_app                started           1/1         64M      1G     holapp.hol.cf-app.com
hol_broker             started           1/1         64M      1G     holbroker.hol.cf-app.com
```

In this example our broker url is holbroker.hol.cf-app.com.

Great! We are now ready to create the Service Broker in kubernetes. This can be done with a simple command.

```
kubectl create -f k8s/resources/broker.yml
```

Congratulations! You have just registered a Service Broker in Kubernetes!

#### Viewing the Services and Service Plans

We can now begin to explore the service offerings and plans that the Service Broker
exposes. In Kubernetes a service offering is referred to as a Service Class. Service
Classes can be made available at the Cluster level, and Namespace level. Namespaces 
in Kuberenetes allow admins to allocate resources to particular users. If a resource 
is available at the cluster level, it is available to all users of the cluster. The
Service Broker we created is a ClusterServiceBroker, and it's Service Classes are visible 
at the Cluster level. We can fetch the Service Classes offered by the broker with this command:

```
kubectl get clusterserviceclasses -l user=$ME -o=custom-columns=NAME:.spec.externalName
```

You should see a list of service names, which you should recognise from when you edited the 
service broker code eariler.

We can also fetch the service plans offered by the broker with this command:
```
kubectl get clusterserviceplans -l user=$ME -o=custom-columns=NAME:.spec.externalName
```

1. K8s walkthrough
-- push the app
cd ~/k8s/app
cat server.js
cat Dockerfile

-- Run the app in the docker image and expose it on port 8080
kubectl run my-app --image=servicesapi/node-env --port=8080
-- The app is now running. Lets expose it so we can talk to it from outside the cluster
kubectl expose deployment my-app --type=LoadBalancer

#### Register broker
vim broker.yml
kubectl create -f broker.yml
-- List services classes offered by the broker
kubectl get clusterserviceclasses -l user=$ME -o=custom-columns=NAME:.spec.externalName
-- List plans for services offered by the broker
kubectl get clusterserviceplans -l user=$ME -o=custom-columns=NAME:.spec.externalName

#### Create a service instance
vim service_instance.yml
kubectl create -f service_instance.yml
- show them the server.js and Dockerfile
- Unknown: push the image? have their username as the image tag
kubectl get services (until the external IP appears)
curl <external IP>:8080

-- Bind to simple app
1. create the service binding
vim service_binding.yml (get the service instance name)
kubectl create -f service-binding.yml
2. Add secrets to the app
kubectl get secrets our-binding -o yaml
vim add-env-to-deployment.yml
kubectl patch deployment my-app --patch "$(cat add-env-to-deployment.yml)"


while IFS= read -r newline; do echo $newline | awk '{ user=$2; sub(/-broker$/, "", user); print "kubectl label clusterserviceplan " $1 " user=" user }' | bash ; done < <(kubectl get clusterserviceplans --watch -l '!user' -o=custom-columns=NAME:.metadata.name,BROKER:.spec.clusterServiceBrokerName --no-headers)


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
