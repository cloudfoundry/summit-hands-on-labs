## Introduction

In this hands on lab, you will deploy a simple application, bind it to a database, scale it, and observe application resiliency.

### Target Audience

 Anyone interested in the basics of deploying apps in Cloud Foundry (developers, operators, biz dev, etc).

### Prerequisites

* Comfortable using a terminal/command line
* A laptop with the ability to install the Cloud Foundry CLI

### Learning Objectives

Learn how to:

* Deploy an application to Cloud Foundry
* Create a service instance from the marketplace and bind it to your application
* Scale your application
* Observe the application resiliency capability of Cloud Foundry

## Lab

### Installing the CLI

The CLI (Command Line Interface) is used to interact with Cloud Foundry.  You can [follow the instructions](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html) to install the CLI on your laptop (which gives you some useful bits like command line completion), or you can download pre-built binaries:

* [MacOS](https://packages.cloudfoundry.org/stable?release=macosx64-binary&source=github)
* [Windows](https://packages.cloudfoundry.org/stable?release=windows64-exe&source=github)
* [Linux](https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github)

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

* You can use `cf login --help` for details on how to log in. The `-a` flag will be needed to specify the API endpoint for Pivotal Web Services (api.run.pivotal.io).

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

Now that you are logged in, you can deploy an application. In Cloud Foundry terms, this is a `cf push`.

* Download the application from Google Drive: https://drive.google.com/uc?id=1s3O1RvCgLdFWHaDT5Dglb_jZP8-P-fMB&export=download
* You can use `cf push --help` to see the details of the `push` command.
* Push your application:

  ```
  $ cf push APP_NAME_IN_CF -p PATH_TO_APPLICATION_JAR -b java_buildpack --random-route
  ```

  Let's dissect the command:

  * `APP_NAME_IN_CF` is the name of the application in Cloud Foundry. It should be a descriptive name for use by humans. Example: `first-push`.
  * `-p` is used to specify the path to the application bits on your local filesystem so the CLI knows what to upload (labeled `PATH_TO_APPLICATION_JAR` files above).
  * `-b java_buildpack` tells Cloud Foundry to use the Java Buildpack to stage the application. You could leave this off and let Cloud Foundry figure it out, but specifying via `-b` is slightly faster.
  * `--random-route` is used to ensure you don't have route conflicts with the other PWS users.

#### Checking Your Work

If everything is successful you should see output for your running application:

```
...
Showing health and status for app first-push in org cloudfoundry-training / space development as sgreenberg@rscale.io...
OK

requested state: started
instances: 1/1
usage: 1G x 1 instances
urls: first-push-variable-ottoman.cfapps.io
last uploaded: Fri Feb 23 16:01:58 UTC 2018
stack: cflinuxfs2
buildpack: java_buildpack

     state     since                    cpu    memory         disk         details
#0   running   2018-02-23 09:03:06 AM   0.0%   278.9M of 1G   171M of 1G
```

The application has a user interface that will show you some details about the application. You can copy the url of your application above and open it in a browser.

### Provisioning a Database

Your app is now running, but it is using an in memory database. If you viewed your application in a browser, you will see it is using an in memory database called `H2`. We need to move this "state" to an external MySQL database.

The Cloud Foundry marketplace shows you a list of available services that can be provisioned on demand.

* You can see the marketplace by running `cf marketplace`. We will be using a MySQL service from `cleardb`.

* You can provision a new instance using `cf create-service`:

  ```
  $ cf create-service cleardb spark SERVICE_NAME_IN_CF
  ```

  Let's dissect the above command:

  * `cleardb` is the service offering.
  * `spark` is the plan or tier.
  * `SERVICE_NAME_IN_CF` is a descriptive name for this MySQL instance as referred to in Cloud Foundry. Again, this name is used by humans. Example: `first-push-db`

#### Checking Your Work

You should be able to see a new service instance using `cf services`:

```
$ cf services
Getting services in org cloudfoundry-training / space development as sgreenberg@rscale.io...
OK

name            service   plan    bound apps   last operation
first-push-db   cleardb   spark                create succeeded
```

### Binding a Database

Now that you have a database instance, you need to tell your application about it.

* You can do this using `cf bind-service`:

  ```
  $ cf bind-service APP_NAME_IN_CF SERVICE_NAME_IN_CF
  ```

* You then need to restart your application so that it picks up the change.

  ```
  $ cf restart APP_NAME_IN_CF
  ```

Binding passes credentials for the database instance to your app through environment variables.

#### Checking Your Work

If you re-run `cf services` you should see your app now bound to your database.

```
$ cf services
Getting services in org cloudfoundry-training / space development as sgreenberg@rscale.io...
OK

name            service   plan    bound apps   last operation
first-push-db   cleardb   spark   first-push   create succeeded
```

You can also refresh your app in the browser and should see it is now using MySQL.

### Scaling

Now that you have state moved to an external service, we can safely scale our application up.

* You can scale to 2 instances using `cf scale`:
  ```
  $ cf scale APP_NAME_IN_CF -i 2
  ```

#### Checking Your Work

You can see the status of your app by running `cf app`:

```
$ cf app APP_NAME_IN_CF
Showing health and status for app first-push in org cloudfoundry-training / space development as sgreenberg@rscale.io...

name:              first-push
requested state:   started
instances:         2/2
usage:             1G x 2 instances
routes:            first-push-variable-ottoman.cfapps.io
last uploaded:     Fri 23 Feb 09:01:58 MST 2018
stack:             cflinuxfs2
buildpack:         java_buildpack

     state      since                  cpu    memory         disk         details
#0   running    2018-02-23T16:12:04Z   0.1%   383.9M of 1G   171M of 1G
#1   starting   2018-02-23T16:24:48Z   0.0%   75.8M of 1G    171M of 1G
```

If you refresh your app in a browser multiple times, you will see the `App Instance Index` change. Cloud Foundry is load balancing your requests across both instances.

### Resiliency

Behind the scenes, Cloud Foundry is also ensuring your application instances are running. To watch this, we will use the Pivotal Web Services console called `Apps Manager`.

> Note: Apps Manager is a Pivotal-only add on to Cloud Foundry.  It is not part of open source Cloud Foundry. We are using it in the interest of time.

* Log in at https://run.pivotal.io.
* You will be taken to an organization where you should see a single space. Click on this space.
* In the space, you will see your application. Click on the application name. This takes you to a detail view for your application.

The application has an endpoint that will programmatically kill the instance answering the request. You will access this endpoint in one browser window before quickly switching back to the `Apps Manager` window.

* Go to your application in a browser. Tack on `/kill` to the URL and hit enter.
* Switch back to the `Apps Manager` window to see the crash and subsequent recovery.
* You can also continue to access your root application URL (not the `/kill` endpoint) and see that you are routed to the live, running instance.

## Learning Objectives Review

In this lab, you:

* Deployed an application to Cloud Foundry using `cf push`.
* Created a service instance from the marketplace (`cf marketplace` and `cf create-service`) and bound it to your application using `cf bind-service`.
* Scaled your application using `cf scale`
* Observed the application resiliency capability of Cloud Foundry by killing an instance.
