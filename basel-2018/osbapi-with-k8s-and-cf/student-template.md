# Open Service Broker API with Cloud Foundry and Kubernetes

## This Worksheet

This worksheet can be found online at https://github.com/ablease/osbapi-lab 

## Introduction

In this lab, students will deploy a very simple Service Broker and then register this Service Broker in Cloud Foundry and Kubernetes.
They will exercise the service instance life cycle and bind a service instance to a sample application in both platforms.

## Learning Objectives

At the end of this lab, students will:

* Know what the Open Service Broker API (OSBAPI) is and why it's beneficial.
* Feel comfortable registering a service broker in both Cloud Foundry and Kubernetes.
* Understand how to create service instances, see service plans, and perform other basic operations in both platforms.

## Prerequisites

* Basic familiarity with the terminal/command line
* Able to use basic features of a terminal text editor vim/emacs/nano

## Lab

Your lab instructors today are Alex and Jen. If you have any questions or problems during the lab, please don't hesitate to raise your hand for one of us to come over.

For this lab, we will be working on a virtual machine that has been pre-provisioned with all the tools we will need. Start by opening a terminal. If you're on a Chromebook you can use the short cut `ctrl-alt-t` to open a terminal. Then open an ssh connection to our virtual machine.

```
ssh <user_name>@jump.sapi.cf-app.com
```

The username and password will be provided to you when you sit down for the lab.

Welcome to the lab!

Explore your home directory. If you run the command `ls`, you should see a folder called `cf` and another called `k8s`.

These folders contain resources that will be used through out the lab.

At some points in the lab you will need to edit some text files via the command line. We have provisioned our machine with vim, emacs and nano. If you are not familiar with command line editing, we recommend using nano. In our examples we will be using vim, but anywhere that you see vim, feel free to substitute it for emacs or nano. 

### Deploy the Service Broker

A Service Broker can provide services for developers to use on platforms like Cloud Foundry and Kubernetes. Some examples of common services include databases, configuration servers and messaging queues. Each service is made up of a number of plans, like ‘small’, ‘medium’ and ‘large’, that developers can choose from when they create backing services for their applications and containers.

A Service Broker is implemented as an HTTP server which coordinates the service lifecycle between a platform (e.g., Cloud Foundry or Kubernetes) and services. The basic operations that a service broker supports are:
1. Provision a new service instance (for example, provision a new MySQL cluster)
1. Bind to a service instance (for example, provide a set of credentials to access that cluster)
1. Unbind (e.g., revoke the credentials)
1. Deprovision (e.g., destroy the cluster)

Each of these operations is provided via an HTTP endpoint on the service broker.

Another responsibility of a Service Broker is to advertise available
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

Below the catalog endpoint you should see some endpoints to do with creating and deleting service instances, and creating and deleting service bindings. Most of these endpoints are no-op dummy endpoints, just to satisfy the Open Service Broker API ("OSBAPI"), but take a closer look at the PUT to `/v2/service_instances/<guid>/service_bindings/<guid>` endpoint. This endpoint provides credentials to access the service instance, and we've provided a sample username and password. Change the username and password values to be anything you want. You'll see this show up later in the lab when we bind to a service instance. 

Now we're going to deploy this service broker so that it can be accessed from both CF and Kubernetes.

Cloud Foundry provides an opinionated and streamlined experience for running an application on the cloud. Remember the haiku?

```
Here is my source code,
run it on the cloud for me,
I do not care how.
```

We will use Cloud Foundry to create a service broker that is running in the cloud!

Change directory into the cf/service-broker directory:

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

---

# Cloud Foundry track

#### Register the Service Broker

Now that we have deployed our service broker, we need to register the broker in Cloud Foundry. This will enable Cloud Foundry users to interact with the services provided by your broker. Let's begin by registering the service broker!

```
cf create-service-broker <broker-name> <username> <password> https://<broker_url> --space-scoped
```

- `<broker-name>` is a unique identifier for this broker across the entire Cloud Foundry instance. We recommend that you choose a broker-name that includes your username.
- The `<username>` and `<password>` fields can be anything. Usually Service Brokers require at least Basic Authentication. Our service broker doesn't require any authentication (which is a terrible idea for any real broker), but Cloud Foundry needs some values to send to the broker.
- `<broker_url>` must be the url of the Service Broker including the protocol. This is the same value you used when curling the broker earlier. If you don't remember the URL, you can retrieve this by running `cf apps`.
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
- `<service-name>` is the name of one of the services you saw from running `cf marketplace`. Pick either one.
- `<service-plan>` is the name of a plan in the service you picked (also visible in `cf marketplace`).
- `<instance-name>` can be anything you want. You will need to refer back to this name later, so you may want it to be short.

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

where `<app-route>` is the route returned at the end of the `cf push` command.

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

- `<app-name>` is the name of your app. You should be able to find it by running `cf apps`
- `<instance-name>` is the name of the service instance you created earlier.

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

---

# Kubernetes Track

Before you start the Kubernetes track, you should have already deployed a Service Broker on Cloud Foundry at the start of this lab.

#### Register the Service Broker
Kubernetes (k8s for short) provides OSBAPI-compliant service functionality via a component called the Service Catalog.

To use the service lifecycle features provided by Service Catalog, you need to register the broker in Kubernetes. This will allow Kubernetes users to interact with services provided by your broker. 

We will create the Service Broker using the `kubectl` tool, which has been pre installed on our machine.

A common pattern across Kubernetes is to use yaml files to describe resources. Typically, when creating any type of resource in Kubernetes, you would create a yaml file to describe the resource, then tell `kubectl` to create the resource described by that file.

We have provided several yaml file templates for you to use during this section of the lab.

Move into the directory with these templates:

```
cd ~/k8s/resources
```

We will start off by registering a Service Broker and pointing it to the service broker app we've deployed in Cloud Foundry. Before modifying the broker.yml file, you'll need the full address of your service broker.

You can get the route of your broker by running `cf apps`:

```
$: cf apps
Getting apps in org lab / space <space> as <your-name>...
OK

name                   requested state   instances   memory   disk   urls
hol_app                started           1/1         64M      1G     holapp.hol.cf-app.com
hol_broker             started           1/1         64M      1G     holbroker.hol.cf-app.com
```

In this example our broker route is holbroker.hol.cf-app.com. Copy the route of your broker, as you'll need it in the next step.

Now, open up the yaml file describing the service broker we want to create:

```
vim broker.yml
```

The important fields are:
- `kind: ClusterServiceBroker` This tells Kuberenetes we want to create a Service Broker
- `metadata.name:` A unique name to identify the broker. We have already filled this in for you. (Please do not change it.)
- `spec.url:` This is the URL of the Service Broker. After the `http`, add the route of your Service Broker that you fetched from `cf apps`.


Great! We are now ready to create the Service Broker in Kubernetes. This can be done with a simple command.

```
kubectl create -f broker.yml
```

This tells Kubernetes to create the resource described by the given yaml file. `kubectl` will return immediately from this command and create the resource asynchronously. To verify that the service broker resource was successfully created, run the following:

```
kubectl get clusterservicebroker <your-service-broker-name> -o yaml
```

Where `<your-service-broker-name>` is the name of your service broker in Kubernetes (found inside the broker.yml file).

You should see a section that looks similar to the following:
```
status:
  conditions: 
  - lastTransitionTime: 2018-04-18T20:40:17Z
    message: Successfully fetched catalog entries from broker.
    reason: FetchedCatalog
    status: "True"
    type: Ready
```

(If you see `conditions` as an empty array, simply wait a bit and try the get command again. If you see an error instead, please contact one of the lab admins and we can help debug.)

Congratulations! You have just registered a Service Broker in Kubernetes!

#### Viewing the Service Classes and Service Plans

We can now begin to explore the service offerings and plans that the Service Broker
exposes. In Kubernetes, the term "Service Class" is used to refer to what is called a "Service" in Cloud Foundry terminology. Service Plans are the same as in Cloud Foundry: they represent different configurations or performance tiers for a given service offering.
In Kubernetes, Service Brokers, Service Classes, and Service Plans are all global across the entire cluster, which is why they all have the `Cluster` prefix in their resource name.

We can fetch the Service Classes offered by the broker with this command:

```
kubectl get clusterserviceclasses -l user=$ME -o=custom-columns=NAME:.spec.externalName
```

The -l flag is filtering all resources so that only the ones that are labelled with your username show up. Because Service Classes are global across the cluster and you are sharing a cluster with other lab participants, you would see other people's brokers if you left off that filter.
The -o flag describes how we want the data to be displayed. In this case, we just want to extract the externalName of the service classes and display it in a column called "NAME".

After running that command, you should see a list of service class names, which you should recognise from when you viewed the 
service broker catalog eariler.

We can also fetch the service plans offered by the broker with this command:
```
kubectl get clusterserviceplans -l user=$ME -o=custom-columns=NAME:.spec.externalName
```

Again, you should recognise these Service Plans, from when you viewed the service broker catalog earlier. 

Now that you have successfully registered the Service Broker in Kubernetes, we can use it to create a service instance.

#### Create a Service Instance

While the previous resources were all global across the entire cluster, Service Instances are scoped to a particular namespace. This is analogous to Service Instances living in a particular space in Cloud Foundry.

To create a service instance we will ask Kubernetes to create a new Service Instance resource. We have provided a yaml file template for the new resource. Let's take a look at it.

```
vim service_instance.yml
```

- `kind: ServiceInstance` tells Kubernetes that we want to create a service instance.
- `metadata.name` will be the name of the Service Instance. We recommend you keep this short and easy to remember.
- `spec.clusterServiceClassExternalName` should be the name of the Service Class that you want to create an instance of. Pick one of the two you saw when listing the ClusterServiceClasses.
- `spec.clusterServicePlanExternalName` should be the name of the Service Plan that you want to create an instance of. Pick one of the two that corresponds to the Service Class you chose.

Once you have finished editing the service instance resource file, we are ready to tell Kubernetes to create the service instance! We can do that by using the familiar `kubectl` command

```
kubectl create -f service_instance.yml
```

To view the Service Instance you just created, you can run the following command:

```
kubectl get serviceinstance <your-service-instance-name> -o yaml
```

The response to that command should eventually include a section similar to the following:

```
status:
  asyncOpInProgress: false
  conditions:
  - lastTransitionTime: 2018-04-18T21:08:23Z
    message: The instance was provisioned successfully
    reason: ProvisionedSuccessfully
    status: "True"
    type: Ready
```

If you see an error here instead, ask for help from a lab admin.

#### Create a Simple App

So far we have used our Service Broker to provision a Service Instance. Now, we want to hook up an application to use this Service Instance. To do that we are going to create a binding, and then tell the app to use the secret created from the binding. But before we do that we need to have an application!

We have provided a very simple app for demonstration purposes. You can take a look at the app code by entering

```
cd ~/k8s/app
less server.js
```

This app checks the value of the `BINDING_USERNAME` and `BINDING_PASSWORD` environment variables, and prints them out. Once we have a Service Binding, we will set these environment variables to take the username and password values from the binding.

Kubernetes apps are deployed as Docker containers, described by Dockerfiles. To see the Dockerfile associated with our simple app, run

```
less Dockerfile
```

We have created this image already and pushed it to to Docker hub, thus you won't be able to modify the server.js or Dockerfile and see the results.

Let's get the app deployed on Kubernetes by running

```
kubectl run <app-name> --image=servicesapi/node-env --port=8080
```

- `<app-name>` is your deployment's name. It should be something short that you can remember later on.
- `--image-servicesapi/node-env` is where our docker image containing the simple app is located on docker hub.
- `--port-8080` this will expose our app on port 8080.

Great, our simple app is now running on Kubernetes, but before we can use it, we need to expose it to allow us to talk to it from outside the cluster. We can do that by running:

```
kubectl expose deployment <app-name> --type=LoadBalancer
```

- `<app-name>` is the name of deployment you created in the last command.

The `expose deployment` command will take a little bit of time to allocate an IP for you app. In the meantime, we will create a Service Binding to fetch a set of credentials from our Service Instance.

#### Create a Service Binding

The term "Service Binding" in Kubernetes means something different than a Service Binding in Cloud Foundry. In Cloud Foundry, a Service Binding is a connection between an app and a Service Instance, usually to provide the app with credentials to access the Service Instance. In Kubernetes, a Service Binding has nothing to do with an app. It represents a connection to a Service Instance which is stored as a secret in Kubernetes. After the binding (and secret) are created, we need to explicitly reference that secret in the deployment to integrate that credential information into our app.

To create a service binding, open up the yaml file representing a Service Binding resource:

```
cd ~/k8s/resources
vim service_binding.yml
```

- `metadata.name` will be the name of your Service Binding (and Secret). We recommend you keep this short and easy to remember.
- `spec.instanceRef.Name` should be the name of the Service Instance you created earlier. If you've forgotten this, just run `kubectl get serviceinstances`.

Once you're finished editing, we can create the Service Binding with the familiar `kubectl` command.

```
kubectl create -f service_binding.yml
```

To verify that your binding and secret were created, you can run:

```
kubectl get servicebindings
```

and 

```
kubectl get secrets
```

In both cases, you should eventually see a row appear with the same name as you gave your service binding.

#### Map the App to the Service Binding

Before you map your app to your new secret, let's verify that your app is reachable and that the environment variables `BINDING_USERNAME` and `BINDING_PASSWORD` are empty.

To get the external IP of your app, run the following command:

```
kubectl get services
```

Note that `services` in this context refers to Kubernetes' own concept of services, which has nothing to do with Service Catalog or the Services we've otherwise been dealing with during this lab.

Curl your app at the external IP you see from the output of that command.

```
curl <external IP>:8080
```

You should see a response like:

```
USERNAME: undefined
PASSWORD: undefined
```

Now we're going to set those environment variables to get their values from the secret you created when you created the Service Binding.

```
vim add-env-to-deployment.yml
```

On line 5, replace the dummy text with the name of your app (aka deployment). In the two `secretKeyRef` sections below, replace the dummy text with the name of your secret (which is also the name of your Service Binding).
This is telling Kubernetes to inject two environment variables into the container running your app, and the `secretKeyRef` describes how to fill the value of those environment variables from a Kubernetes secret.

All we have left now is to patch the deployment with the file you just edited!

```
kubectl patch deployment <app-name> --patch "$(cat add-env-to-deployment.yml)"
```

Wait a second or two, and then curl your Kubernetes app like you did before.

```
curl <external IP>:8080
```

This time, you should see the USERNAME and PASSWORD values as they exist in your service broker code.

Congratulations! You've created a service instance from the same broker in Cloud Foundry and Kubernetes, and given apps in both platforms access to your Service Instance!

## Learning Objectives Review

Now that you've deployed a service broker and used it to create dummy service instances and bindings in both CF and Kubernetes, you should:
* Understand the value of having a single API for both platforms to use when talking to service brokers.
* Know how to register a service broker in both Cloud Foundry and Kubernetes.
* Understand how to create service instances, see service plans, and perform other basic operations in both platforms.

## Beyond the Lab

Write a real service broker:
* On-Demand Service Broker: https://github.com/pivotal-cf/on-demand-service-broker
* SUSE Universal Service Broker: https://github.com/suse/cf-usb
* The OSBAPI Spec: https://github.com/openservicebrokerapi/servicebroker/blob/master/spec.md

Go further with CF:
* Getting Started: https://www.cloudfoundry.org/get-started/
* Services in Cloud Foundry: https://docs.cloudfoundry.org/services/

Go further with K8s:
* Getting started with Minikube: https://kubernetes.io/docs/tutorials/stateless-application/hello-minikube/
* Service Catalog: https://kubernetes.io/docs/concepts/service-catalog/
