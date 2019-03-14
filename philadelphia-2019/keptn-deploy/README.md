## Introduction

In this hands-on lab, you will learn how to automatically deploy an app - and new artifacts of this app - into a multi-stage environment using [keptn](keptn.sh). Therefore, keptn relies on the GitOps approach and maintains the stage configurations in a GitHub repository. In more details, each stage is represented by an individual branch that contains the entire configuration (e.g., manifests) for the stage. After creating the project (repository), the app that is going to be managed by keptn need to be onboarded. Therefore, keptn provides the functionality to upload the manifest of the onboarded app to each stage. 

### Target Audience

 Anyone interested in the basics of deploying apps in Cloud Foundry (developers, operators, biz dev, etc).

### Prerequisites

* Comfortable using a terminal/command line

### Learning Objectives

Learn how to:

* Deploy an application to Cloud Foundry using keptn
* ...

Understand how:

* keptn uses the GitOps approach to manage the app configurations
* ...

## Lab

### Step 1. Using the keptn CLI

### Step 2. Onboard a new app

After authorizing the cli, you are ready to onboard the first app.

1. Onboard the `carts` app using the `keptn onboard service` command.

    ```console
    $ keptn onboard service --project=sockshop --manifest=manifest_carts.yaml
    ```

### Step 3. Create a new artifact

1. After creating onboarding a app, open Jenkins and go to **carts** > **master** > **Build Now**.

### Step 4. Watch keptn deploying the app

1. Go back to the Jenkins dashboard to see how the invidiual steps of the CD pipeline get triggered.

## Learning Objectives Review

In this lab, you:

* ...

## Beyond the Lab

