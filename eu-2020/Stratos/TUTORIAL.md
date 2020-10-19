<walkthrough-watcher-constant key="stratos-namespace" value="stratos-namespace">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="stratos-port" value="30891">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="kube-node-url" value="!!kube_node_url!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="seat" value="!!seat_number!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="stratos-helm-name" value="stratos-console">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="kube-url" value="!!kube_url!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="kube-token" value="!!kube_token!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="kube-endpoint-name" value="my-kube-cluster">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="wordpress-name" value="my-wordpress">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="wordpress-namespace" value="my-wordpress-namespace">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="cf-endpoint-name" value="my-cf">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="cf-url" value="https://api.hol.starkandwayne.com">
</walkthrough-watcher-constant>

## Set up your personal environment

The script should have successfully completed and set up your environment.

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
   export STRATOS_NAMESPACE={{stratos-namespace}}
   ```
1. Now create a Kube Namespace with it
   ```bash
   kubectl create namespace $STRATOS_NAMESPACE
   ```
1. Install Stratos in the new namespace
   ```bash
   helm install {{stratos-helm-name}} stratos/console --namespace=$STRATOS_NAMESPACE -f stratos-values.yaml
   ```
   This will start the install. Helm will provide Kubernetes with a set of resources to create. The resources are rendered from helm templates with help from the `stratos-values.yaml` we have provided. By using a custom values file we've 
   - defined how we can reach Stratos
   - enabled 'Tech Preview' features
   - set up a local user credentials for a quick way to log in

1. Wait for the install to complete. Run the following command and wait for all the pods to be ready or completed
   ```bash
   watch -n 1 kubectl get pods -n $STRATOS_NAMESPACE
   ``` 
   
### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Log in
1. Open the Stratos URL in your local browser
   ```
   {{kube-node-url}}:30981
   ```

   > Note - No SLL certificates have not been configured, so accept any invalid certificate warnings

1. Enter the pre-configured Stratos credentials
   
   Username: `admin`

   Password: `password`

## Register and Connect a Kubernetes Endpoint

Stratos uses endpoints to communicate with other systems such as Cloud Foundries, Kubernetes, Helm Repositories, etc. A Stratos Administrator will register these endpoints in Stratos and then all users can connect to it using their own credentials.

In this step we will register and connect to a personal Kubernetes Cluster.

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Register
1. Navigate to the Endpoints page via the side navigation buttons on the left

1. Click on the `+` icon to the right of the header

1. Click on `Kubernetes`

1. Call your new Kube Endpoint `{{kube-endpoint-name}}`

1. Enter the Kube Cluster's API URL as the Endpoint Address
   ```
   {{kube-url}}
   ```

1. Check the `Skip SSL validation for the endpoint` box

1. Click `Register` in the bottom right

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Connect
1. Check the `Connect to {{kube-endpoint-name}} now` box

1. In the `Auth Type` drop down select `Service Account Token`

1. Copy in your service token into the text area below the drop down
   ```
   {{kube-token}}
   ```

1. Click `Connect`

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Confirm
1. Confirm your new Endpoint is shown in the Endpoints list and that it's status is `Connected`

1. Click on the `Kubernetes` button in the sidenav on the left

1. Explore the Pods view by clicking on the `Pods` button in the sub-sidenav. 
   Can you find the Stratos pods in the pods view?

## Register Helm Endpoints and Install a Chart

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Register the Artifact Hub Endpoint
Artifact Hub is an online collection of Helm Repositories. By adding it as an Endpoint all charts from it's repo's are available

1. Navigate to the Endpoints page via the side navigation buttons on the left

1. Click on the `+` icon to the right of the header

1. Click on `Artifact Hub`

1. Click `Register` in the bottom right

## Install Wordpress

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Install
1. Navigate to the Helm Charts list by clicking on the `Helm` button in the sidenav on the left

1. Find the Wordpress chart by filtering the list with `wordpress`

1. Click on the `bitnami/wordpress` chart to see the chart summary

1. Click on the `Install` button towards the top right

1. Add `{{wordpress-name}}` as the name

1. Add `{{wordpress-namespace}}` as the namespace
   - This namespace doesn't not exist, so check the `Create Namespace` button

1. Click `Next`

1. The next step entails supplying values for the helm install, just like we did when installing stratos with `-f stratos-values.yaml`. This chart has a schema, but we're going to enter the following yaml after clicking on the `YAML` button near the top left
   ```
   wordpressPassword: password
   service:
     type: NodePort
     nodePorts:
       https: 30982
   ```
   This will determine how we access and sign in to wordpress 

1. Click `Install`. You will be taken to the `Workload` page for the new `Stratos`

1. Wait for the Workload Pods to come up. To see these navigating to the `Pods` page of the Workload that's automatically been navigated to.
   - Just like watching these pods come up in the CLI they should be marked as ready and have a positive status.

1. Navigate to Wordpress in a new browser tab
   ```
   {{kube-node-url}}:30982
   ```
   > Note: In Stratos we can see the port number in the `Workload`'s `Services` page

1. Log in to the new Stratos using the same credentials
   
   Username: `admin`

   Password: `password`

## Explore Kubernetes Features

Explore some of the new Kubernetes features, there's some suggestions below.

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Browse Kube State and Resources
1. Navigate to the Kubernetes list by clicking on the `Kubernetes` button in the sidenav on the left

1. See the status of the cluster using the graphs

1. Look at node information after clicking on the `Nodes` button in the sub-sidenav

1. Browse resources in namespaces by clicking on the `Namespaces` button in the sub-sidenav

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> View a Workload
1. Navigate to the Workloads list by clicking on the `Workloads` button in the sidenav on the left

1. Find the workload for Stratos, it should be named `{{stratos-helm-name}}`, and click on it

1. See the status of the Pods and Containers in the `Summary` page

1. View the contents of `stratos-values.yaml` used when installing Stratos in the `Values` page

1. Check that the Pods all have an acceptable `Status` in the `Pods` page.

1. Find the `Node Port` of the `{{stratos-helm-name}}-ui-ext` service that exposes access to Stratos

## Explore Kubernetes Tech Preview Features

Explore some of the new Tech Preview Kubernetes features, there's some suggestions below.

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Configure and View the Kubernetes Dashboard
1. Navigate to the Summary page of your Kubernetes by clicking on the `Kubernetes` button in the sidenav on the left

1. Click on `Configure` in the `Kubernetes Dashboard` section

1. Click on `Install Dashboard` on the bottom right of the `Kubernetes Dashboard Installation` card

1. Click on `Create Service Account` on the bottom right of the `Service Account` card

1. Stratos will spin up the Kube Dashboard in a pod. We can see the status of this by going to the `Kubernetes` `Pods` view.

1. Go back to the summary page by clicking the `Kubernetes` button in the sidenav

1. Click on `View Dashboard` in the sub-header

1. You should now see the well known Kubernetes Dashboard application, take some time to explore

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Run an Analysis tool

Kubernetes analysis tools are a new feature which allows the execution of external tool. There's one available at the moment called PopEye.

1. Navigate to the Workloads list by clicking on the `Workloads` button in the sidenav on the left

1. Find the workload for Stratos, it should be named `{{wordpress-name}}`, and click on it

1. Click on the `Analysis` button in the sub-sidenav

1. Click on `Run Analysis` in the sub-header at the top and select `PopEye`

1. Wait a moment... and then click on `Refresh` in the `Reports` drop down in the sub-header

1. When the new run appears in the drop down click it

1. Browse the information found in the report

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Bring up a Kube & Helm terminal environment in Stratos
The Kube & Helm terminal provides a shell like experience with the Kube and Helm CLI tools configured and authorised to communicate with the Kube Cluster

1. Navigate to the Summary page of your Kubernetes by clicking on the `Kubernetes` button in the sidenav on the left

1. Click on `Open Terminal` in the button in the sub-header

1. Execute the following to see Stratos's own pods
   ```
   kubectl get pods --namespace {{stratos-namespace}
   ```
   > Get your namespace by running `echo $STRATOS_NAMESPACE` in the Google Cloud Shell
   > Note - See the `terminal-` pod that hosts the terminal

1. Execute the following to see the Stratos's own chart
   ```
   helm list -A
   ```

1. Exit there terminal by navigating away from this page

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> View an Overview Graph
The overview graph provides a way to see 

1. Navigate to the Workloads list by clicking on the `Workloads` button in the sidenav on the left

1. Find the workload for Stratos, it should be named `{{stratos-helm-name}}`, and click on it

1. Click on the `Overview` button in the left sub-sidenav

1. Zoom in to discover how the Stratos kubernetes resources connect to each other

1. If you have run a PopEye analysis select it as an overlay to see the warnings


## Extra Credit - Explore some existing Cloud Foundry Features

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Register and Connect a CF Endpoint

1. Navigate to the Endpoints page via the side navigation buttons on the left

1. Click on the `+` icon to the right of the header

1. Click on `Cloud Foundry`

1. Call your new Kube Endpoint `{{cf-endpoint-name}}`

1. Enter the Kube Cluster's API URL as the Endpoint Address
   ```
   {{cf-url}}
   ```

1. Check the `Skip SSL validation for the endpoint` box

1. Click `Register` in the bottom right

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Connect
1. Check the `Connect to {{cf-endpoint-name}} now` box

1. Enter the your credentials

   Username: `{{seat}}-summitlabs@cloudfoundry.org`

   Password: `SummitLabs{{seat}}`

1. Click `Connect`


### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Browse Applications 
1. Click on the `Applications` button in the sidenav

1. Here you would see all applications in Spaces your user is a member of

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Deploy an Application
1. Click on the `+` button in the header

1. Click on `Public GitHub` 

1. Select `{{cf-endpoint-name}}` as your Cloud Foundry, `cf-summit` as your organisation and `stratos-{{seat}}` as your space

1. Click `Next`

1. For you project enter 
   ```
   cf-stratos/cf-quick-app
   ```

1. Click `Next`

1. In the next step leave the first commit selected and click `Next`

1. In the next step leave all overrides as they are and click `Deploy` to kick it off

1. Wait for the Deployment to complete by viewing the logs, the below line should be shown
   ```
   #0   running   2020-10-19T14:35:03Z   0.0%   0 of 16M   0 of 64M   
   ```

1. Click on `Go to App Summary` and explore the Application functionality provided by Stratos, including those in the sub-sidenav

## Summary
We hoped you've enjoyed this hands on. You should now have an understanding of how to...

- Install Stratos via Kubernetes
- Create and connect to Stratos Endpoints, including Kubernetes, Helm and Cloud Foundry
- View Kubernetes information in Stratos, including Workloads
- Browse and install Helm charts
- Browse and deploy CF Applications

If you would like to know more about Stratos please reach out to us via our github repo https://github.com/cloudfoundry/stratos or directly in the Cloud Foundry #stratos slack room.

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy> 