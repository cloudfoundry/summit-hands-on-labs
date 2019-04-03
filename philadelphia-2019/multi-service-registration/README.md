# Multi Service Registration

## Introduction

Your lab instructors today are Alex and Aarti, engineers on the Services API team. If you have any questions or problems during the lab, please don't
hesitate to raise your hand for one of us to come over.

Welcome to the lab!

In this lab, attendees will deploy a very simple Service Broker and then register this Service Broker in different
spaces of Cloud Foundry. Also, attendees will explore registering the same broker multiple times and see how this
effects creating service instances. 

## Learning Objectives

At the end of this lab, attendees will:

* Have a better understanding of why multi service registration feature was built.
* Explore one of the expected use cases of Multi Service Registration.
* Feel comfortable registering a service broker in Cloud Foundry.
* Understand how to create service instances, see service plans, and perform other basic operations.

## Prerequisites

* Basic familiarity with the terminal/command line

## Lab

For this lab, we will be working on a Chromebook.

If you run the command `ls`, you should see a folder called `service-broker`.

### Check that Cloud Foundry is setup

We have created a Cloud Foundry user for you to use throughout this lab with the Space Developer role. This role allows you to push applications
and create space scoped service brokers. 

Let's begin! First off please login to your Cloud Foundry Account.

```
cf login -a api.phillyhol.starkandwayne.com --skip-ssl-validation
```

At the prompt, enter your designated music genre as the username, and the password is password.

Target your organization. The organization name, is the same as your user name

```
cf target -o <your-user-name>
```

Check that you have access to the dev and prod space. 

```
cf spaces
```

You should see both the dev and prod spaces listed.

Target the dev space

```
cf target -s dev
```

---

### Deploy the Service Broker

A Service Broker can provide services for developers to use on platforms like Cloud Foundry. Some examples of common services include databases,
configuration servers and messaging queues. Each service can be presented in various configuration options or plans, like ‘small’, ‘medium’
and ‘large’. Developers can select which plan of a given service best fits the needs of their application.

A Service Broker is implemented as an HTTP server which coordinates the service lifecycle between a platform (e.g., Cloud Foundry or Kubernetes)
and services.
The basic operations that a service broker supports are:
1. Provision a new service instance (for example, provision a new MySQL cluster)
1. Bind to a service instance (for example, provide a set of credentials to access that cluster)
1. Unbind (e.g., revoke the credentials)
1. Deprovision (e.g., destroy the cluster)

Each of these operations is provided via an HTTP endpoint on the service broker.

Another responsibility of a Service Broker is to advertise available
Services and Service Plans. This is done by exposing a catalog endpoint, which
responds with descriptions of the Services and Plans in JSON format.

We are providing a simple Service Broker for use in this lab called [overview-broker](https://github.com/mattmcneeney/overview-broker).
The overview-broker is a simple service broker conforming to the Open Service Broker API specification that hosts a dashboard showing information 
on service instances and bindings created by any platform the broker is registered with.

Now we're going to deploy this service broker by pushing it as an application to Cloud Foundry.  

Cloud Foundry provides an opinionated and streamlined experience for running an application on the cloud. Remember the haiku?

```
Here is my source code,
run it on the cloud for me,
I do not care how.
```

We will use Cloud Foundry to create a service broker that is running in the cloud!

Change directory into the service-broker directory:

```
cd ~/service-broker
```

Push the service broker application to Cloud Foundry

```
cf push <username>-broker
```

This will take a minute or so.

You can verify that your service broker is running by pasting the link into a new browser tab. 

(You can see the broker URL in the output of `cf push`)

Congratulations you have deployed a service broker! You Rock!

---

### Register the Service Broker

Now that we have deployed our service broker, we need to register the broker in Cloud Foundry. This will enable Cloud Foundry users to interact
with the services provided by your broker. Let's begin by registering the service broker!

```
cf create-service-broker <broker-name> admin password http://<broker_url> --space-scoped
```

- `<broker-name>` is a unique identifier for this broker across the entire Cloud Foundry instance. We recommend that you choose a broker-name that includes your username.
- The `<username>` and `<password>` fields can be anything. Usually Service Brokers require at least Basic Authentication. Our service broker doesn't require any authentication (which is a terrible idea for any real broker), but Cloud Foundry needs some values to send to the broker.
- `<broker_url>` must be the url of the Service Broker including the protocol. This is the same value you used when curling the broker earlier. If you don't remember the URL, you can retrieve this by running `cf apps`.
- The `--space-scoped` flag is required for this lab. By default, service brokers are registered across the entire Cloud Foundry instance, which requires admin privileges. Since the lab users accounts are not admins, you will create a service broker that only you can see and use.

### Viewing the Services and Service Plans

To view the services in the marketplace, enter

```
cf marketplace
```

You should see something similar to this

```
cf marketplace
Getting services from marketplace in org system / space dev as admin...
OK


service                         plans             description                                                                                        broker
overview-service                simple, complex   Provides an overview of any service instances and bindings that have been created by a platform.   overview-broker
overview-service-volume-mount   simple, complex   Provides an example volume mount service.                                                          overview-broker
```

The marketplace gives a description of each service, and tells us what plans are available for each service. This comes directly from the catalog endpoint of the service broker.

---

### Register the Service Broker in another space

Target the prod space

```
cf target -s prod
```

Register the service broker in prod space

```
cf create-service-broker <broker-name> admin password http://<broker_url> --space-scoped
```

What do you see?

Creating the broker fails with an error that the broker name is taken. That is because we are using the same broker name which was used to register
the service broker in the dev space. Service Broker names are identifiers that are unique across the Cloud Foundry instance.

To fix this error, create a service broker with a different name.


```
cf create-service-broker <new-broker-name> admin password http://<broker_url> --space-scoped
```

With this feature, it's also possible to register the same broker again in the same space, with the requirement that the broker name should be unique.
Let's try that out.

```
cf create-service-broker <another-broker-name> admin password http://<broker_url> --space-scoped
```

You should now see the services from both the brokers in the marketplace.

```
cf m
Getting services from marketplace in org acceptance / space temp as admin...
OK

service                         plans             description                                                                                        broker
overview-service                simple, complex   Provides an overview of any service instances and bindings that have been created by a platform.   temp-overview-broker
overview-service-volume-mount   simple, complex   Provides an example volume mount service.                                                          temp-overview-broker
overview-service                simple, complex   Provides an overview of any service instances and bindings that have been created by a platform.   second-temp-overview-broker
overview-service-volume-mount   simple, complex   Provides an example volume mount service.                                                          second-temp-overview-broker
```

Notice how there appear to be duplications of services offered in our marketplace. These services can be differentiated by the fact that they are offered by different brokers,
according to the broker column.

---

### Create A Service Instance

Great! We are now in a position where we can ask a service broker to create an instance of one of its services. To do this we need to tell it which service we want, and which plan we want.
We will also have to provide a name, which will be used to identify our instance.

```
cf create-service <service-name> <service-plan> <instance-name>
```
- `<service-name>` is the name of one of the services you saw from running `cf marketplace`. Pick either one.
- `<service-plan>` is the name of a plan in the service you picked (also visible in `cf marketplace`).
- `<instance-name>` can be anything you want. You will need to refer back to this name later, so you may want it to be short.

```
cf create-service overview-service simple <instance-name>

Creating service instance my-service in org acceptance / space temp as admin...
Service 'overview-service' is provided by multiple service brokers. Specify a broker by using the '-b' flag.
FAILED
```

This is because the service is being offered by both brokers, but the new flag `-b` helps resolve this ambiguity. 
Let's choose one of the brokers to create the service instance.

```
cf create-service -b <broker-name> overview-service simple <instance-name>
```

What's happening under the hood here:
- We asked Cloud Foundry to create a service instance, from a particular Service Broker
- Cloud Foundry has sent a request to the `PUT /v2/service_instance` endpoint of the named Service Broker
- Cloud Foundry internally creates a record of this service instance, which you can refer to via the name you gave it.

For details about your service instance, run:

```
cf service <instance-name>
```

This will show you the current state of your instance, if there are any bound applications and the Service Broker it was created by.

---

Congratulations! You have completed the Lab.

---

## Learning Objectives Review

Now that you've successfully completed the lab, you should:
* Know how to deploy and register a service broker in Cloud Foundry multiple times.
* Understand some of the reasons why it is necessary to register the same Service Broker multiple times
* Understand how to create service instances, when there are multiple offerings of the same service in the marketplace

## Beyond the Lab

* Getting Started: https://www.cloudfoundry.org/get-started/
* Services in Cloud Foundry: https://docs.cloudfoundry.org/services/
* Multi-Service-Registration deep dive document: https://docs.google.com/document/d/1_OBnFCsL3ru43PEXocsCc3EuGaM0YLHjr0iAoXnakt4
* Cloud Foundry documentation, Managing Service Brokers: https://docs.cloudfoundry.org/services/managing-service-brokers.html
* Open Service Broker API Specification: https://www.openservicebrokerapi.org/

