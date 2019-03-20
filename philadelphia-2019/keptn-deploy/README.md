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

### Step 1. Authenticate keptn CLI

1. Authentication against the keptn installation using the `keptn auth` command:

    ```console
    $ keptn auth --endpoint=https://keptn-endpoint --api-token=***
    ```

## Step 2: Create project for your app

Before creating a project, you need to define a *shipyard* file that describes the multi-stage environment you want to use for your project. Such a *shipyard* files defines the name, deployment strategy and test strategy of each stage. In this lab, you will rely on following multi-stage environment: 

```yaml
stages:
  - name: "dev"
    deployment_strategy: "direct"
    test_strategy: "functional"
  - name: "staging"
    deployment_strategy: "direct"
    test_strategy: "performance"
  - name: "production"
    deployment_strategy: "direct"
```

1. Create a new project for your app using the `keptn create project` command. In this example, the project is called *keptn-hol* and please add your initials, e.g.: *keptn-hol-JB*

    ```console
    $ ls
    $ keptn create project keptn-hol-JB shipyard.yaml
    ```

### Step 2. Onboard a new app

After authorizing the cli and creating a project, you are ready to onboard the first app.

1. Change the manifest file to a unique app name.

1. Onboard the `spring-music` app using the `keptn onboard service` command. As project, please reference your project you created before.

    ```console
    $ keptn onboard service --project=keptn-hol-JB --manifest=manifest.yml
    ```

### Step 3. Create a new artifact

After onboarding an app, a new artifact need to be created. To keep this lab focused on the main aspects, the artefact has already been created. However, you need to update the reference to this new artifact in the configuration of your application. Therefore, a simple Jenkins pipeline is provided.

1. Use a browser to open Jenkins with the url `jenkins.keptn.EXTERNAL-IP.xip.io` and login using the default Jenkins credentials: `admin` / `AiTx4u8VyUV8tCKk`.

1. Select the new-artefact pipeline and click on *Build Now*.

### Step 4. Watch keptn deploying the application

1. Go back to the Jenkins dashboard to see how the invidiual steps of the CD pipeline get triggered.

## Learning Objectives Review

In this lab, you:

* ...

## Beyond the Lab

