<walkthrough-watcher-constant key="stratos_namespace" value="stratos-namespace">
</walkthrough-watcher-constant>
<walkthrough-watcher-constant key="stratos_url" value="!!stratos_url!!">
</walkthrough-watcher-constant>
<walkthrough-watcher-constant key="stratos_port" value="30891">
</walkthrough-watcher-constant>
<walkthrough-watcher-constant key="seat" value="!!seat number!!">
</walkthrough-watcher-constant>
<walkthrough-watcher-constant key="stratos_helm_name" value="stratos-console">
</walkthrough-watcher-constant>

## Introduction

In this hands-on lab attendees will learn how to install Stratos to Kubernetes using Helm. They will then learn how to register and connect different types of Stratos endpoints and use them to explore the new Kubernetes and Helm functionality in Stratos. 

### Steps

The presenters will demonstrate each step. Time and assistance will then be provided for attendees to complete each step before the presenters continue onto the next.

## Set up your personal environment

Welcome to your GCS Session. The rest of the tutorial can be done in this environment and one other browser tab.

In this step we will set up some CLI tools and test them.

### Authorise Google Cloud Shell with Google Compute API
1. Allow your session user to access the required APIs by clicking on the button below and accepting the permissions

   <walkthrough-enable-apis apis="compute.googleapis.com">Enable the Compute API</walkthrough-enable-apis>

   Alternatively enable APIs from the command line with:

   ```bash
   gcloud services enable compute container compute.googleapis.com --project summit-labs
   ```
### <walkthrough-cloud-shell-icon></walkthrough-cloud-shell-icon> Install Tools, Get Kube Credentials
1. Run the following script
   ```bash
   ./setup-env.sh
   ```

   The script will 
   - install the `helm` CLI and configure it and `kubectl` to communicate with your own Kube Cluster that we have assigned to your user.
   - create a Service Token that Stratos will use to communicate with the cluster.
   - update and reload the tutorial

   Ensure that the script completes successfully, it should print `Set up complete`

1. Apply the environment variables
   ```bash
   source user-env
   ```

1. If your shell ever restarts, just run the following commands to get back to the correct state
   ```bash
   ~/cloudshell_open/summit-hands-on-labs-0/eu-2020/Stratos
   ```
   ```bash
   source user-env
   ```

### <walkthrough-cloud-shell-icon></walkthrough-cloud-shell-icon> Validate your environment
1. Can you fetch Kubernetes namespaces?
   ```bash
   kubectl get ns
   ```

1. Can you list all Helm Repositories
   ```bash
   helm list -A
   ```

## Install Stratos using Helm

In this step we will find the Stratos Helm Chart via the Stratos Helm Repo, install that chart and then log in to Stratos

### <walkthrough-cloud-shell-icon></walkthrough-cloud-shell-icon> Add the Stratos Helm Repository (& update)
1. Add the Stratos Helm Rep and update the local cache
   ```bash
   helm repo add stratos https://cloudfoundry.github.io/stratos
   ```
   ```bash
   helm repo update   
   ```
   The repository contains a set of charts and their historic versions.

1. Find the Stratos Chart
   ```bash
   helm search repo console
   ```
   Here you can see the Stratos Helm Chart called 'console'.

### <walkthrough-cloud-shell-icon></walkthrough-cloud-shell-icon> Install Stratos
1. Create a variable with the namespace
   ```bash
   export stratos_namespace={{stratos_namespace}}
   ```
1. Now create a Kube Namespace with it
   ```bash
   kubectl create namespace $stratos_namespace
   ```
1. Install Stratos in the new namespace
   ```bash
   helm install {{stratos_helm_name}} stratos/console --namespace=$stratos_namespace -f stratos-values.yaml
   ```
   This will start the install. Helm will provide Kubernetes with a set of resources to create. The resources are rendered from helm templates with help from the `stratos-values.yaml` we have provided. By using a custom values file we've 
   - defined how we can reach Stratos
   - enabled 'Tech Preview' features
   - set up a local user credentials for a quick way to log in

1. Wait for the install to complete. Run the following command and wait for all the pods to be ready or completed
   ```bash
   watch -n 1 kubectl get pods -n $stratos_namespace
   ``` 
   
### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Log in
1. Open the Stratos URL in your local browser
   ```
   https://{{stratos_url}}:{{stratos_port}}
   ```
   > Note - No SLL certificates have not been configured, so accept any invalid certificate warnings

1. Enter the pre-configured Stratos credentials
   
   Username: `admin`

   Password: `password`

## Register and Connect a Kubernetes Endpoint

Stratos uses endpoints to communicate with other systems such as Cloud Foundries, Kubernetes, Helm Repositories, etc. A Stratos Administrator will register these endpoints in Stratos and then all users can connect to it using their own credentials.

In this step we will register and connect to a personal Kubernetes Cluster.

### <walkthrough-cloud-shell-icon></walkthrough-cloud-shell-icon> Find the Kube Cluster's URL and Service Token
1. Kube Cluster's API URL
   This can be found by running the following from the shell
   ```bash
   echo $KUBE_URL
   ```
1. Kube Cluster's Service Token
   This can also be found by running the following from the shell
   ```bash
   echo $KUBE_TOKEN
   ```

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Register
1. Navigate to the Endpoints page via the side navigation buttons on the left

1. Click on the `+` icon to the right of the header

1. Click on `Kubernetes`

1. Add a recognisable name for your new Kube Endpoint

1. Enter the Kube Cluster's API URL as the Endpoint Address

1. Check the `Skip SSL validation for the endpoint` box

1. Click `Next` in the bottom right

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Connect
1. Check the `Connect to <your endpoint name> now` box

1. In the `Auth Type` drop down select `Service Account Token`

1. Copy in your service token into the text area below

1. Click `Next`

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Confirm
1. Confirm your new Endpoint is shown in the Endpoints list and that it's status is `Connected`

1. Click on the `Kubernetes` button in the sidenav on the left

1. Can you find the Stratos pods in the pods view?

## Register Helm Endpoints and Install a Chart

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Register a Artifact Hub Endpoint
Artifact Hub is an online collection of Helm Repositories. By adding it as an Endpoint all charts from it's repo's are available

1. Navigate to the Endpoints page via the side navigation buttons on the left

1. Click on the `+` icon to the right of the header

1. Click on `Artifact Hub`

1. Click `Register` in the bottom right

<!-- // TODO: Add helm repo -->

## Install and uninstall Stratos using Stratos

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Install

1. Navigate to the Helm Charts list by clicking on the `Helm` button in the sidenav on the left

1. Find the Stratos chart and click on it
   > Hint - Search for `console`

1. Click on the `Install` button towards the top right

1. Add `{{stratos_helm_name}}-2` as the name

1. Add `{{stratos_namespace}}-2` as the namespace
   - This namespace doesn't not exist, so check the `Create Namespace` button

1. Click `Next`

1. Here we need to supply similar contents to our `stratos-values.yaml` file used earlier. The Stratos Helm Chart has a schema, so Stratos can display a dynamically created form for those values. For ease though switch to the `YAML` editor using the button near the top left and enter the values below
   ```
   console:
      localAdminPassword: "password"
      service:
         type: "NodePort"
         nodePort: 30892
      techPreview: true
   ```
   > Note - These are the same values from the file except for the different node port

1. Click `Install`. You will be taken to the `Workload` page for the new `Stratos`

1. Wait for the Workload Pods to come up. To see these navigating to the `Pods` page of the Workload that's automatically come up.
   - Just like watching these pods come up in the CLI they should be marked as ready and have a positive status.

1. Discover the URL for the new Stratos
   - Use the same address as the old Stratos but update the port to the one defined in values - `30892`
   - The port number can also been seen in the `Workload`'s `Services` page for the `<x>-ui-ext` service

1. Navigate to the new Stratos in the same tab

1. Log in to the new Stratos using the same credentials
   
   Username: `admin`

   Password: `password`

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Uninstall
1. Navigate to the Workloads list by clicking on the `Workloads` button in the sidenav on the left

1. Find the workload for the new Stratos, it should be named `{{stratos_helm_name}}-2`, and click on it

1. Click on the `Delete` button in the top sub-header

1. Enter the name of the workload `{{stratos_helm_name}}-2` and click `Delete`


<!-- // TODO: install previous version...see no kube stuff... then upgrade with new features? -->
<!-- // TODO: install with kube stuff disabled? tech preivew off? -->

## Explore a Kubernetes Features

Explore some of the new Kubernetes features, there's some suggestions below.

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Browse Kube State and Resources
1. Navigate to the Kubernetes list by clicking on the `Kubernetes` button in the sidenav on the left

1. See the status of the cluster using the graphs

1. Look at node information after clicking on the `Nodes` button in the sub-sidenav

1. Browse resources in namespaces by clicking on the `Namespaces` button in the sub-sidenav

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> View a Workload
1. Navigate to the Workloads list by clicking on the `Workloads` button in the sidenav on the left

1. Find the workload for Stratos, it should be named `{{stratos_helm_name}}`, and click on it

1. See the status of the Pods and Containers in the `Summary` page

1. View the contents of `stratos-values.yaml` used when installing Stratos in the `Values` page

1. Check that the Pods all have an acceptable `Status` in the `Pods` page.

1. Find the `Node Port` of the `{{stratos_helm_name}}-ui-ext` service that exposes access to Stratos

## Explore Tech Preview Features

Explore some of the new Tech Preview Kubernetes features, there's some suggestions below.

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Configure and View the Kubernetes Dashboard
1. Navigate to the Summary page of your Kubernetes by clicking on the `Kubernetes` button in the sidenav on the left

1. Click on `Configure` in the `Kubernetes Dashboard` section

1. Click on `Install Dashboard` on the bottom right of the `Kubernetes Dashboard Installation` card

1. Click on `Create Service Account` on the bottom right of the `Service Account` card

1. Pause, great things come to those that wait!

1. Click on the name of your kube cluster in the breadcrumb in the header, this will take you back to the summary page for your cluster

1. Click on `View Dashboard` in the sub-header

1. You should now see the well known Kubernetes Dashboard application, take some time to explore

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Run an Analysis tool
Kubernetes analysis tools are a new feature which allows the execution of external tool. There's one available at the moment called PopEye.

1. Navigate to the Summary page of your Kubernetes by clicking on the `Kubernetes` button in the sidenav on the left

1. Click on the `Analysis` button in the sub-sidenav on the left

1. Click on `Run Analysis` in the sub-header at the top and select `PopEye`
   - The run should then appear in the table below

1. Click on the report name in the table to view the report
   - This will be a link once the run has `Completed`
1. Browse the information found in the report

1. Click on the `Analysis` link in the sub-header or click on the `Analysis` button in the sidenav on the left to return to the Analysis page

1. Delete the run by selecting the three vertical dots in the row in the table and selecting `Delete`

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Bring up a Kube & Helm terminal environment in Stratos
The Kube & Helm terminal provides a shell like experience with the Kube and Helm CLI tools configured and authorised to communicate with the Kube Cluster

1. Navigate to the Summary page of your Kubernetes by clicking on the `Kubernetes` button in the sidenav on the left

1. Click on `Open Terminal` in the button in the sub-header

1. Execute the following to see Stratos's own pods
   ```
   kubectl get pods --namespace <your namespace>
   ```
   > Get your namespace by running `echo $stratos_namespace` in the Google Cloud Shell
   > Note - See the `terminal-` pod that hosts the terminal


<!-- // TODO: doesn't work for artifact hub¬¬  -->
1. Execute the following to see the Stratos's own chart
   ```
   helm search repo console
   ```

1. Exit there terminal by navigating away from this page

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> View an Overview Graph
The overview graph provides a way to see 

1. Navigate to the Workloads list by clicking on the `Workloads` button in the sidenav on the left

1. Find the workload for Stratos, it should be named `{{stratos_helm_name}}`, and click on it

1. Click on the `Overview` button in the left sub-sidenav

1. Zoom in to discover how the Stratos kubernetes resources connect to each other

1. If you have run a PopEye analysis select it as an overlay to see the warnings


## Extra Credit - Explore some existing Cloud Foundry Features

<!-- // TODO: all . use stark and wayne cf -->

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Register and Connect a CF Endpoint

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Browse Applications 

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Deploy an Application

## Summary
We hoped you have enjoyed this hands on... etc
<!-- // TODO: all . use stark and wayne cf -->

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy> 