## Introduction

In this lab, students will deploy a very simple Service Broker and then register this Service Broker in Cloud Foundry and Kubernetes.
They will exercise the service instance life cycle and bind a service instance to a sample application in both platforms.

## Learning Objectives
At the end of this lab, students will:

* Know what the Open Service Broker API (OSPABI) is and why it's beneficial. TODO need to summarize this somewhere!
* Feel comfortable registering a service broker in both Cloud Foundry and Kubernetes
* Understand how to create service instances, see service plans, and other basic operations in both platforms.

## Prerequisites

* Basic familiarity with the terminal/command line
* Able to use basic features of a terminal text editor vim/emacs/nano

## Lab

For this lab, we will be working on a virtual machine that has been pre provisioned with
all the tools we will need. Start by opening a terminal. If you're on a Chromebook
you can use the short cut `ctrl-alt-t` to open a terminal. Then open an ssh connection
to our virtual machine.

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

### Deploy the Service Broker
<!--  - Open up the service broker code and catalog (explain services, plans, and instances) -->
<!-- 2. Deploy the service broker to your CF space -->

We are providing a very simple service broker for use in this lab. The Service Broker
is a web application that has been written in node.js. You can view the source code
of the Service Broker by running

```
less cf/service-broker/server.js
```

Our Service Broker exposes a set of endpoints that will serve requests for various
operations. At the top is a `get '/v2/catalog'` endpoint. Every Service Broker
must provide a way for clients to discover what services it offers. The response
to this endpoint will be a JSON object which contains information about
the services and configuration options or plans for each service.

Below the catalog endpoint you should see some endpoints to do with creating and
deleting service instances, and creating and deleting service bindings. We will
go into more detail around these endpoints later on in the lab. For now, lets move
on to deploying our super simple broker!
TODO this is a dummy broker

When you are done viewing the service broker code, press `q` to exit less.

Cloud Foundry provides an opinionated and streamlined experience for running an application
on the cloud. Remember the haiku?

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

Congratulations you have deployed a service broker! You Rock!

From here you can start the Cloud Foundry track, or the Kubernetes Track. You
can do both of them, in any order. It's recommended to start the Cloud Foundry
track if you are not already familiar with these concepts.

### Cloud Foundry track

#### Create the Service Broker
Now that we have deployed our service broker, we need to register the broker in
Cloud Foundry. This will enable Cloud Foundry to render the Service Brokers
catalog and present the services in a friendly way. Lets begin by registering
the service broker!

```
cf create-service-broker <broker-name> <username> <password> https://<broker_url> --space-scoped
```

- <broker-name> can be anything you like. It is used to create a unique identifier
for the Service Broker.
- The <username> and <password> fields can be anything. Usually Service Brokers
require at least Basic Authentication. Our service broker doesn't
require any authentication, but Cloud Foundry will reject this command if we
don't provide any values here.
- <broker_url> must be the url of the Service Broker including the protocol.
To get the url of the Service Broker you can enter `cf apps`

The `--space-scoped` flag is required since our user account in Cloud Foundry
only has write and read permissions in the space we are currently targeting. You
can type `cf target` to see which space you are currently targeting. It should
look similar to your user name. Spaces in Cloud Foundry are a mechanism by which
Cloud Foundry resources can be allocated to users.  TODO make this description of spaces better

#### Enable Service Access
Now that we have created a Service Broker in Cloud Foundry, we should ask Cloud Foundry
to allow developers in our space to have access to the broker. To do this we
need to enable access to services offered by the Broker. We can do this using
the `cf enable-service-access` command

```
cf enable-service-access fake-mysql-NAMESPACE
cf enable-service-access fake-redis-NAMESPACE
```

What's happened under the hood here, is that we have asked Cloud Foundry to
fetch the brokers Catalog, and for services that match the fake-mysql or fake-redis
names, populate the Cloud Foundry marketplace.

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
fake-mysql-NAMESPACE   mysql-top-tier, mysql-free         A fake non-operational mysql service
fake-redis-NAMESPACE   redis-small-mem, redis-large-mem   The best fake redis
```

The marketplace gives a description of each service, and tells us what plans are
available for each service.

#### Create A Service Instance
Great! We are now in a position where we can ask the service broker to create
an instance of one of its services. To do this we need to tell it which service
we want, and which plan we want. We will also have to provide a name, which will
be used to identify our instance if the service

```
cf create-service fake-mysql-NAMESPACE mysql-free my-mysql-instance
```

Whats happening under the hood here:
- We asked Cloud Foundry to create a service instance for us on our behalf
- Cloud Foundry has sent a request to the `'put /v2/service_instance` endpoint of the Broker
- The Broker has responded with 200 OK which tells us that the service instance
  already exists and is fully provisioned (actually this was a no-op in our broker)

```
cf service my-mysql-instance
```

#### Create a Simple app

So far we have used our Service Broker to Provision  a service instance, based
on the type of service offered by the broker, and the configuration options
available in the plans. We want to hook up an application to use this service
instance. To do that we are going to create a binding. But before we do that
we need to have an application to bind the service to!

We have provided a very simple app for demonstration purposes. You can view the
app code by entering

```
less ~/cf/simple-app/server.js
```

Again this is a very app written in node.js. When no service is bound to this
app, it will print "No services instances are bound to this app". When a service
instance is bound to this app, it will print the username and password present
in the binding.

When you are done viewing the source code of the app, close less by pressing
`q`.

Lets push the app to the cloud!
```
cd ~/cf/simple-app && cf push
```

Once the app has been deployed lets curl it to check its current state.

```
curl appname.hol.cf-app.com
No service instances are bound to this app.
```

So we have our app running on the cloud, great! Now can explore the binding
a service instance to our application using our Service Broker. In Cloud 
Foundry, the end result of a service biniding is that an application has
credentials for a service instance injected into an environment variable.

#### Create a Service Binding

Lets ask Cloud Foundry to create a binding between our service instance
and our application. 

```
cf bind-service app-name service-instance
```

After we make this request there are various things that happen behind
the scenes. 
Firstly Cloud Foundry sends a request to the service broker to create a
service binding. The Service Broker must respond and some credentials
in JSON format. Cloud Foundry takes these credentials and delivers them to
our application via an environment variable

If we restage our application now, we will see the environment variable
changes take effect. 

```
curl appname.hol.cf-app.com
Credentials available: username is 'admin' and password is 'passw0rd'
```

Congratulations! You have finished the Cloud Foundry track. If you 
like move onto the Kuberenetes Track


1. CF walkthrough
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
 - cf restage my-app
 - curl <app-address>

### Kubernetes Track

Before you start the Kubernetes track you should have already deployed a Service
Broker. If you have not already done so please start here TODO link to create a sb step

#### Create the Service Broker
Now that you have deployed a Service Broker, we need to register the broker
in Kubernetes! This will allow us to view the services and plans offered by
the broker. 

We will create the service broker using the `kubectl` Command Line Interface, which
has been pre provisioned on our machine.

We ask Kubernetes to create our Service broker based on a small manifest. Let's
take a look at this manifest

```
less k8s/resources/broker.yml
```

Here we provide some instructions to Kubernetes regarding the type of resource we want
to create. The important fields are:
- `kind: ClusterServiceBroker` This tells Kuberenetes we want to create a Service Broker
- `metadata.name:` A unique name to identify the Broker, we have auto generated this for you
- `spec.url:` This is the location of the Service Broker. We will need to edit it this,







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
