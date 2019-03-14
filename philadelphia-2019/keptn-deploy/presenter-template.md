# Lab Description

In this hands-on lab, attendees will learn how to automatically deploy a app - and new artifacts of this app - into a multi-stage environment using [keptn](keptn.sh). Keptn relies on the GitOps approach and maintains the stage configurations in a GitHub repository. In more details, each stage is represented by an individual branch that contains the entire configuration (e.g., manifests) for the stage. After creating the project (repository), the app that is going to be managed by keptn need to be onboarded. Therefore, keptn provides the functionality to upload the manifest of the onboarded app to each stage. 

# Program Description

*Another lab description for publishing in the CF Summit program.*

# Environment

This section describes the lab environment that is necessary for the attendees to run through the lab.

Requirements:
  * one shared CF environment with three spaces: dev, staging, and production
  * keptn cli - from [keptn 0.2](https://github.com/keptn/keptn/releases)

# Setup

To run this lab, the following items must be available in advance:

* A successful keptn installation
* The endpoint and API token provided by the keptn installation. This endpoint and API token are used by the CLI to send commands to the keptn installation.
* A GitHub organization, user, and personal access token, which are used by keptn.

* A **keptn project**, that will contain all apps from the attendees:
    ```console
    $ keptn create project cf-hands-on-lab shipyard.yaml
    ```

# Issues
