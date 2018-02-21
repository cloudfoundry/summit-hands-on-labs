## Introduction

In this hands on lab, you will deploy a simple application, bind it to a database, scale it, and observe application resiliency.

## Prerequisites

* Comfortable using a terminal/command line
* A Cloud Foundry account on a hosted provider
* A laptop with the ability to install the Cloud Foundry CLI

## Learning Objectives

Learn how to:

* Deploy an application to Cloud Foundry
* Create a service instance from the marketplace and bind it to your application
* Scale your application
* Observe the application resiliency capability of Cloud Foundry

## Lab

### Installing the CLI

The CLI (Command Line Interface) is used to interact with Cloud Foundry.

* Follow the instructions to install the CLI on your laptop: https://docs.cloudfoundry.org/cf-cli/install-go-cli.html

#### Checking Your Work

If you installed the CLI successfully, you should be able to open a terminal window and see the version of the CLI.

```
$ cf version
6.33.0+a345ea34d.2017-11-20
```

### Using the CLI

The CLI is a self-documenting tool. You will use the `help` capability to complete the exercises below.

You can run:

* `cf help` to see a list of the most commonly used commands
* `cf help -a` to see a list of all the available commands
* `cf <command> --help` to see details on using a specific command

### Logging In

When using Cloud Foundry, the first thing you need to do is target and log in to a Cloud Foundry instance.

* You can use `cf login --help` for details on how to log in. The `-a` flag will be needed to specify the  API endpoint for Pivotal Web Services (api.run.pivotal.io).

  ```
  $ cf login -a api.run.pivotal.io
  ```

* You will be prompted for your username and password (provided by your instructor).

#### Checking Your Work

If you log in successfully, you should see output similar to below:

```
Authenticating...
OK

Targeted org cloudfoundry-training

Targeted space development

API endpoint:   https://api.run.pivotal.io (API version: 2.103.0)
User:           sgreenberg@rscale.io
Org:            cloudfoundry-training
Space:          development
```

### Deploying to Cloud Foundry

Now that you are logged in, you can deploy an application. In Cloud Foundry terms, this means doing a `cf push`.








## Learning Objectives Review
