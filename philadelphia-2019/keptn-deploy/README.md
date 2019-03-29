## Introduction

In this hands-on lab, you will learn how to automatically deploy an app - and new artifacts of this app - into a multi-stage environment using [keptn](keptn.sh). Therefore, keptn relies on the GitOps approach and maintains the stage configurations in a separate GitHub repository. In more details, each stage is represented by an individual branch that contains the entire configuration (e.g., app manifests) for the stage. After creating the repository, the app that is going to be managed by keptn needs to be onboarded. Therefore, keptn provides the functionality to upload the manifest of the onboarded app to each stage. 

### Target Audience

Anyone interested in the basics of deploying apps in Cloud Foundry (developers, operators, biz dev, etc).

### Prerequisites

* Comfortable using a terminal/command line

### Learning Objectives

Learn how to:
* set up the configuration for a multi-stage CF environment
* deploy an application to Cloud Foundry using keptn
* trigger the continuous delivery pipeline by providing a new artefact

Understand how:
* keptn uses the GitOps approach to manage the app configurations
* keptn uses an event-driven approach to launch continuous delivery tasks

## Lab

### Step 1. Authenticate the keptn CLI

1. Authentication against the keptn installation using the `keptn auth` command:

    ```console
    $ keptn auth --endpoint=https://keptn-endpoint --api-token=***
    ```

## Step 2: Create project for your app

Before creating a project, you need to define a *shipyard* file that describes the multi-stage environment you want to use for your project. Such a *shipyard* files defines the name of each stage and can specify the deployment strategy and test strategy for each stage. In this lab, you will rely on following multi-stage environment: 

```yaml
stages:
  - name: "dev"
    deployment_strategy: "direct"
  - name: "staging"
    deployment_strategy: "direct"
  - name: "production"
    deployment_strategy: "direct"
```

1. Create a new project for your app using the `keptn create project` command. In this example, the project is called *keptn-hol* and please add your initials, e.g.: *keptn-hol-JB*

    ```console
    $ cat shipyard.yml
    $ keptn create project keptn-hol-JB shipyard.yml
    ```

1. Verify the project creation by navigating to your GitHub repository in the `keptn-deploy` organization.
    * Go to: `https://github.com/keptn-deploy`
    * Click on your repository: `keptn-hol-JB`
    * Click on the **Branch: master** button to see the three branches for your multi-stage environment that are: *dev*, *staging*, and *production*.

### Step 2. Onboard a new app

After authorizing the cli and creating a project, you are ready to onboard the first app. In this lab, you will onboard the [spring-music](https://github.com/cloudfoundry-samples/spring-music) app based on the following steps.

1. Change the manifest file to a unique app name by adding your initials, e.g.: *spring-music-JB*

    ```console
    $ vi manifest.yml
    $ cat manifest.yml
    ---
    applications:
    - name: spring-music-JB
      memory: 1G
      random-route: true
      path: spring-music.jar
    ```

1. Onboard the `spring-music` app using the `keptn onboard service` command. For the project option, please reference your project you created in step 2.

    ```console
    $ keptn onboard service --project=keptn-hol-JB --manifest=manifest.yml
    ```

1. Verify the app onboarding by navigating to your GitHub repository in the `keptn-deploy` organization.
    * Go to: `https://github.com/keptn-deploy`
    * Click on your repository: `keptn-hol-JB`
    * Click on the **Branch: master** button to switch to the *dev* branch. There you will find the manifest for your app.

### Step 3. Learn about the GitOps approach

Your instructor will explain the basic concepts behind GitOps approach and how to apply it for managing your configurations.

### Step 4. Create a new artifact

After onboarding an app, a new artifact needs to be created. To keep this lab focused on the main aspects, the artefact has already been created. However, you need to update the reference to this new artifact in the configuration of your application. Therefore, a simple Jenkins pipeline is provided.

1. Use a browser to open Jenkins with the url `jenkins.keptn.EXTERNAL-IP.xip.io` and login with the following Jenkins credentials: `admin` / `AiTx4u8VyUV8tCKk`.

1. Select the new-artefact pipeline and click on *Build Now*.

1. Change the following parameters:
    * **PROJECT**: specify your project, e.g.: *keptn-hol-JB*
    * **APP**: specify your spring-music app, e.g.: *spring-music-JB*

### Step 5. Watch keptn deploying the application

Deploying the application into the *dev*, *staging* and *production* environment takes about 6 minutes. In the meanwhile, your instruct will explain you how keptn works behind the scene.

1. Verify the configuration change in your GitHub repository.

1. Go back to the Jenkins dashboard to see how the individual steps of the CD pipeline get triggered.

## Learning Objectives Review

In this lab, you:

* Set up the configuration for a multi-stage environment using `keptn create project`
* Onboarded an app to your project using `keptn onboard service`
* Triggered the continuous delivery pipeline by providing a new artefact

## Beyond the Lab

[Keptn](keptn.sh) is an open-source project with the goal to build an enterprise-grade framework for shipping and running cloud-native applications. Find more information on [GitHub](https://github.com/keptn/keptn) or on the keptn website. 

**Feel free to contribute or reach out to the keptn team using a channel provided [here](https://github.com/keptn/community)** 