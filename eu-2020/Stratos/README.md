## Introduction

In this hands-on lab attendees will learn how to install Stratos to Kubernetes using Helm. They will then learn how to register and connect different types of Stratos endpoints and use them to explore the new Kubernetes and Helm functionality in Stratos. 

### Steps

The presenters will demonstrate each step. Time and assistance will then be provided for attendees to complete each step before the presenters continue onto the next.

## Access your personal environment

In this step we will gather your lab credentials and set up your Google Cloud Shell environment

### Claim your Google Credentials
1. Open (?) <!-- // TODO: url to google sheet  -->

1. Claim a row by adding your name to the `Stratos` column

1. Make a note of your credentials

### Start Google Cloud Shell 
1. Open the link below in incognito/private mode <!-- // TODO: add why -->

1. Log in using your claimed credentials from above

1. Find this README in a window on the right
   - If this fails to show then execute the following command in the `cloudshell`
     ```
     teachme README.md
     ```
<!-- // TODO: this should be updated with the correct repo -->

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_branch=rc&cloudshell_git_repo=https%3A%2F%2Fgithub.com%2Fcf-stratos%2Fsummit-hands-on-labs&cloudshell_working_dir=eu-2020%2FStratos&cloudshell_tutorial=README.md&shellonly=true&cloudshell_print=welcome.txt)



## Set up your personal environment

Welcome to your GCS Session. The rest of the tutorial can be done in this environment and one other browser tab.

In this step we will set up some CLI tools and test them.

### Install Tools, Get Kube Credentials
1. Run the following script
   ```
   source setup-env.sh
   ```
   This will install the `helm` CLI and configure it and `kubtectl` to communicate with your own Kube Cluster that we have assigned to your user.
   It will also create a Service Token that Stratos will use to communicate with the cluster

### Validate your environment
1. Can you fetch Kubernetes namespaces?
   ```
   kubectl get ns
   ```

1. Can you list all Helm Repositories (there will be no repositories to show)?
   ```
   helm repo list 
   ```

## Install Stratos using Helm

In this step we will find the Stratos Helm Chart via the Stratos Helm Repo, install that chart and then log in to Stratos

### Add the Stratos Helm Repository (& update)
1. Add the Stratos Helm Rep and update the local cache
   ```
   helm repo add stratos https://cloudfoundry.github.io/stratos
   ```
   ```
   helm repo update   
   ```
   The repository contains a set of charts and their historic versions.

1. Find the Stratos Chart
   ```
   helm search repo console
   ```
   Here you can see the Stratos Helm Chart called 'console'.

### Install Stratos
1. Create a Kube Namespace for Stratos
   ```
   export sn=stratos
   kubectl create namespace $sn
   ```
1. Install Stratos in the new namespace
   ```
   helm install stratos-console stratos/console --namespace=$sn -f stratos-values.yaml --devel // TODO: Remove --devel
   ```
   This will start the install. Helm will provide Kubernetes with a set of resources to create. The resources are rendered from helm templates with help from the `stratos-values.yaml` we have provided. By using a custom values file we've 
   - defined how we can reach Stratos
   - enabled 'Tech Preview' features
   - set up a local user credentials for a quick way to log in

1. Discover the URL of Stratos
   ```
   export NODE_PORT=$(kubectl get --namespace $sn -o jsonpath="{.spec.ports[0].nodePort}" services console-ui-ext)
   export NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[?(@.type==\"ExternalIP\")].address}")
   export STRATOS_URL=https://$NODE_IP:$NODE_PORT
   echo "The URL of your new Stratos is $STRATOS_URL"
   ```

1. Wait for the install to complete
   ```
   watch -n 1 kubectl get pods -n $sn
   ``` 
   
### Log in
1. Open the Stratos URL in your local browser

1. Enter the pre-configured Stratos credentials
   Username: 'admin'
   Password: 'password'

## Register and Connect a Kubernetes Endpoint

Stratos uses endpoints to communicate with other systems such as Cloud Foundries, Kubernetes, Helm Repositories, etc. A Stratos Administrator will register these endpoints in Stratos and then all users can connect to it using their own credentials.

### Find the Kube Cluster's URL and Service Token
1. Kube Cluster's API URL
   This can be found by running the following from the shell
   ```
   echo $KUBE_URL
   ```
1. Kube Cluster's Service Token
   This can also be found by running the following from the shell
   ```
   echo $KUBE_TOKEN
   ```

### Register
1. Navigate to the Endpoints page via the side navigation buttons on the left
1. Click on the `+` icon to the right of the header
1. Click on `Kubernetes`
1. Add a recognisable name for your new Kube Endpoint
1. Enter the Kube Cluster's API URL as the Endpoint Address
1. Click Next in the bottom right

### Connect
1. Check the `Connect to` box
1. Select `Service Account Token` as the `Auth Type`
1. Copy in your service token into the text area below
1. Click next

### Confirm
1. Confirm your new Endpoint is shown in the Endpoints list and that it's status is `Connected`
1. Click on the `Kubernetes` button in the sidenav on the left
1. Can you find the Stratos pods in the pods view?

## Register a Helm Repo Endpoint and Install a Chart
<!-- // TODO: Intro -->
<!-- // TODO: steps -->

## Explore a Kubernetes Features

Explore some of the new Kubernetes features, there's some suggestions below.

#### View a Workload
<!-- // TODO: explain what workloads are -->
1. Navigate to the Workloads list by clicking on the `Workloads` button in the sidenav on the left
1. Find the workload for Stratos, it should be named `stratos-console`, and click on it
<!-- 1. // TODO: more activities -->

## Explore Tech Preview Features

Explore some of the new Tech Preview Kubernetes features, there's some suggestions below.



#### Configure and View the Kubernetes Dashboard
1. Navigate to the Summary page of your Kubernetes by clicking on the `Kubernetes` button in the sidenav on the left
1. Click on `Configure` in the `Kubernetes Dashboard` section
1. Click on `Install Dashboard` on the bottom right of the `Kubernetes Dashboard Installation` card
1. Click on `Create Service Account` on the bottom right of the `Service Account` card
1. Pause, great things come to those that wait!
1. Click on the name of your kube cluster in the breadcrumb in the header, this will take you back to the summary page for your cluster
1. Click on `View Dashboard` in the sub-header
1. You should now see the well known Kubernetes Dashboard application, take some time to explore

#### Run an Analysis tool
<!-- // TODO: explain what workloads are -->
1. Navigate to the Summary page of your Kubernetes by clicking on the `Kubernetes` button in the sidenav on the left
1. Click on the `Analysis` button in the sub-sidenav on the left
1. Click on `Run Analysis` in the sub-header at the top and select `PopEye`
   - The tun should then appear in the table below
1. Click on the report name in the table to view the report   
   - This will be a link once the run has `Completed`
1. Click on the `Analysis` link in the sub-header or click ont he `Analysis` button in the sidenav on the left to return to the Analysis page
1. Delete the run by selecting the three vertical dots in the row in the table and selecting `Delete`

#### Bring up a Kube & Helm terminal environment in Stratos
<!-- // TODO: explain what the terminal is -->
1. Navigate to the Summary page of your Kubernetes by clicking on the `Kubernetes` button in the sidenav on the left
1. Click on `Open Terminal` in the button in the sub-header
1. Execute the following to see Stratos's own pods
   ```
   kubectl get pods --namespace stratos
   ```
1. Execute the following to see the Stratos's own chart
   ```
   helm search repo console
   ```
1. Exit there terminal by navigating away from this page


## Extra Credit(??)
<!-- // TODO: Is this needed? -->
1. Register CF
1. Deploy an cf application
1. View cf app instances as kube pods

