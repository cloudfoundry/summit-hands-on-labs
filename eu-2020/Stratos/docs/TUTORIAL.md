<walkthrough-watcher-constant key="stratos-namespace" value="!!stratos_namespace!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="stratos-port" value="!!stratos_port!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="kube-node-url" value="!!kube_node_url!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="kube-node-ip" value="!!kube_node_ip!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="seat" value="!!seat_number!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="stratos-helm-name" value="!!stratos_helm_name!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="kube-url" value="!!kube_url!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="kube-token" value="!!kube_token!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="kube-endpoint-name" value="!!kube_endpoint_name!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="wordpress-name" value="!!wordpress_helm_name!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="wordpress-namespace" value="!!wordpress_namespace!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="cf-endpoint-name" value="!!cf_endpoint_name!!">
</walkthrough-watcher-constant>

<walkthrough-watcher-constant key="cf-url" value="!!cf_endpoint_url!!">
</walkthrough-watcher-constant>

## Set up your personal environment

### <walkthrough-notification-menu-icon></walkthrough-notification-menu-icon> Validate script
1. Ensure that the script completes successfully, it should print **Set up complete**.

### <walkthrough-cloud-shell-icon></walkthrough-cloud-shell-icon> Validate your environment
1. Can you fetch Kubernetes namespaces?
   ```bash
   kubectl get ns
   ```

1. Can you list all Helm releases?
   > Note This will be an empty list

   ```bash
   helm list -A
   ```

## Install Stratos using Helm

In this step we will find the Stratos Helm Chart via the Stratos Helm Repo, install that chart and then log in to Stratos.

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
   helm install {{stratos-helm-name}} stratos/console --namespace=$STRATOS_NAMESPACE -f yaml/stratos-values.yaml --version "4.2.0"
   ```
   This will start the install. Helm will provide Kubernetes with a set of resources to create. The resources are rendered from helm templates with help from the `stratos-values.yaml` we have provided. By using a custom values file we've 
   - defined how we can reach Stratos
   - enabled 'Tech Preview' features
   - set up a local user credentials for a quick way to log in

1. Run the following command
   ```bash
   watch -n 1 kubectl get pods -n $STRATOS_NAMESPACE
   ``` 

1. Wait for all the pods to come up
   - The **READY** column shows all containers have started e.g. 1/1, 2/2, etc
   - The **STATUS** column shows all pods as **Running**

1. Exit the **watch** command by entering **CTRL + C**
   
### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Log in
1. Open the Stratos URL in your local browser

   ```
   https://{{kube-node-ip}}:{{stratos-port}}
   ```

   > Note - No SLL certificates have not been configured, so accept any invalid certificate warnings

1. Enter the pre-configured Stratos credentials
   
   Username: **admin**

   Password: **password**

## Register and Connect a Kubernetes Endpoint

Stratos uses endpoints to communicate with other systems such as Cloud Foundrys, Kubernetes, Helm Repositories, etc. A Stratos Administrator will register these endpoints in Stratos and then all users can connect to it using their own credentials.

In this step we will register and connect to a personal Kubernetes Cluster.

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Register
1. Navigate to the Endpoints page via the side navigation buttons on the left (if you've just logged in you should be hello lovely bum there already).

1. Click on the **+** icon to the right of the header

1. Click on **Kubernetes**

1. Call your new Kube Endpoint the following
   ```
   {{kube-endpoint-name}}
   ```

1. Enter the Kube Cluster's API URL as the Endpoint Address
   ```
   {{kube-url}}
   ```

1. Check the **Skip SSL validation for the endpoint** box

1. Click **Register** in the bottom right

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Connect

1. Check the **Connect to {{kube-endpoint-name}} now** box

1. In the **Connection Credentials** section change the **Auth Type** drop down to **Service Account Token**

1. Copy in your service token into the text area below the drop down
   ```
   {{kube-token}}
   ```

1. Click **Connect**

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Confirm
1. Confirm your new Endpoint is shown in the Endpoints list and that it's status is **Connected**

1. Click on the **Kubernetes** button in the sidenav on the left

1. Explore the Pods view by clicking on the **Pods** button in the sub-sidenav. 
   Can you find the Stratos pods in the pods view?

## Register a Helm Endpoint and Install WordPress

To enable Helm functionality, just like Kubernetes we need to add a Helm endpoint. Once added we can view the Helm Chart's it offers and use Stratos to install one to our Kubernetes Cluster.

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Register the Artifact Hub Endpoint
Artifact Hub is an online collection of Helm Repositories. By adding it as an Endpoint all charts from it's repo's are available

1. Navigate to the Endpoints page via the side navigation buttons on the left

1. Click on the **+** icon to the right of the header

1. Click on **Artifact Hub**

1. Click **Register** in the bottom right

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Install WordPress
1. Navigate to the Helm Charts list by clicking on the **Helm** button in the sidenav on the left

1. Find the WordPress chart by filtering the list with the text
   ```
   wordpress
   ```

1. Click on the **bitnami/wordpress** chart to see the chart summary

1. Click on the **Install Chart** button towards the top right

1. Keep **{{kube-endpoint-name}}** as the Kubernetes cluster

1. Add the following as the **Name**
   ```
   {{wordpress-name}}
   ```

1. Add the following as the **Namespace**
   ```
   {{wordpress-namespace}}
   ```
   - This namespace doesn't not exist, so check the **Create Namespace** button

1. Click **Next**

1. The next step entails supplying values for the helm install, just like we did when installing stratos with **-f stratos-values.yaml**. This chart has a schema, but we're going to enter the following yaml after clicking on the **YAML** button near the top left
   ```
   wordpressPassword: password
   service:
     type: NodePort
     nodePorts:
       http: 30892
   ```
   This will determine how we access and sign in to wordpress 

1. Click **Install**. You will be taken to the **Workload** page for your new WordPress.

1. Wait for the Workload Pods to come up. To see these navigating to the **Pods** via the button in the side-subnav of the Workload that's automatically been navigated to.
   - The **Ready** column shows all containers have started e.g. 1/1, 2/2, etc
   - The **Status** column shows all pods as **Running**
   > Note - This page will automatically update
   > Note - This will take about 60 seconds

1. Navigate to WordPress in a new browser tab
   ```
   http://{{kube-node-ip}}:30892
   ```
   > Note: In Stratos we can see the port number in the **Workload**'s **Services** page

1. (Optional) Log in to WordPress by clicking on the **Log In** link in the **Meta** section at the bottom and entering the credentials below
   
   Username: **user**

   Password: **password**

## Explore Kubernetes Features

Explore some of the new Kubernetes features, there's some suggestions below.

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Browse Kube State and Resources
1. Navigate to the Kubernetes list by clicking on the **Kubernetes** button in the sidenav on the left

1. See the status of the cluster using the graphs

1. Look at node information after clicking on the **Nodes** button in the sub-sidenav

1. Browse resources in namespaces by clicking on the **Namespaces** button in the sub-sidenav

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> View a Workload
1. Navigate to the Workloads list by clicking on the **Workloads** button in the sidenav on the left

1. Find the workload for Stratos, it should be named **{{stratos-helm-name}}**, and click on it

1. See the status of the Pods and Containers in the **Summary** page

1. View the contents of **stratos-values.yaml** used when installing Stratos in the **Values** page

1. Check that the Pods all have an acceptable **Status** in the **Pods** page.

1. Find the **Node Port** of the **{{stratos-helm-name}}-ui-ext** service that exposes access to Stratos by clicking on the **Services** button in the sub-sidenav

## Explore Kubernetes Tech Preview Features

Explore some of the new Tech Preview Kubernetes features, there's some suggestions below.

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Configure and View the Kubernetes Dashboard
1. Navigate to the Summary page of your Kubernetes by clicking on the **Kubernetes** button in the sidenav on the left

1. Click on **Configure** in the **Kubernetes Dashboard** section in the centre of the page

1. Click on **Install Dashboard** on the bottom right of the **Kubernetes Dashboard Installation** card

1. Click on **Create Service Account** on the bottom right of the **Service Account** card

1. Stratos will spin up the Kube Dashboard in a pod. We can see the status of this by 
   1. Navigating to the **Kubernetes** section by clicking on the sidenav
   1. Clicking on the **Pods** sub-sidenav button
   1. Clicking the circle button in the lists header on the right to refresh the list to refresh the list
   1. Filter the list by adding the following
      ```
      dashboard
      ```
   1. Finding the Pod with **Name** **kubernetes-dashboard-<random characters>**

1. Go back to the summary page by clicking the **Kubernetes** button in the sidenav

1. Click on **View Dashboard** in the sub-header

1. You should now see the well known Kubernetes Dashboard application, take some time to explore

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Run an Analysis tool

Kubernetes analysis tools are a new feature which allows the execution of external tool. There's one available at the moment called PopEye.

1. Navigate to the Workloads list by clicking on the **Workloads** button in the sidenav on the left

1. Find the workload for WordPress, it should be named **{{wordpress-name}}**, and click on it

1. Click on **Run Analysis** in the sub-header at the top and select **PopEye**

1. Wait a moment... click on **Refresh** in the **Overlay Analysis** drop down in the sub-header and select **Popeye (a few seconds ago)** (you may need to click on **Refresh** again)

1. Look at the resource cards at the bottom of the screen, they should now show any information provided by Popeye for that resource type. Click on the yellow button in **Pods** to see this information

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> View an Overview Graph
The overview graph provides a way to see Kubernetes resources and how they connect to each other.

1. If you've clicked away from the WordPress Workload page follow the steps below
  1. Navigate to the Workloads list by clicking on the **Workloads** button in the sidenav on the left
  1. Find the workload for WordPress, it should be named **{{wordpress-name}}**, and click on it

1. Click on the **Overview** button in the left sub-sidenav

1. Zoom in to discover how the WordPRess Kubernetes resources connect to each other

1. If you have run a PopEye analysis select it as an overlay and click on the resource to see the warnings

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Bring up a Kube & Helm terminal environment in Stratos
The Kube & Helm terminal provides a shell like experience with the Kube and Helm CLI tools configured and authorised to communicate with the Kube Cluster.

1. Navigate to the Summary page of your Kubernetes by clicking on the **Kubernetes** button in the sidenav on the left

1. Click on **Open Terminal** in the button in the sub-header and wait for the command prompt

   > Note - This may not be instant, please allow some time for Kubernetes to fetch the require image

   > Note - The terminal will have the correct credentials to communicate with all registered and connected Kubernetes Clusters

1. Type and execute the following to see Stratos's own pods

   **kubectl get pod -n {{stratos-namespace}}**

   > Note - See the **terminal-** pod that hosts the terminal

1. Type and execute the following to see the Stratos's own chart

   **helm list -A**

   > Note - See the Stratos and Wordpress installs

1. Exit there terminal by navigating away from this page


## Extra Credit - Explore some existing Cloud Foundry Features

You can view some of the existing Cloud Foundry functionality by following the steps below to connect to a Cloud Foundry and deploy an application to it.

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Register and Connect a CF Endpoint

1. Navigate to the Endpoints page via the side navigation buttons on the left

1. Click on the **+** icon to the right of the header

1. Click on **Cloud Foundry**

1. Call your new Endpoint the following
   ```
   {{cf-endpoint-name}}
   ```

1. Enter the Kube Cluster's API URL as the Endpoint Address
   ```
   {{cf-url}}
   ```

1. Check the **Skip SSL validation for the endpoint** box

1. Click **Register** in the bottom right

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Connect
1. Check the **Connect to {{cf-endpoint-name}} now** box

1. Enter the your credentials

   Username:
   ```
   {{seat}}-summitlabs@cloudfoundry.org
   ```

   Password:
   ```
   SummitLabs{{seat}}
   ```

1. Click **Connect**


### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Browse Applications 
1. Click on the **Applications** button at the top of the sidenav

1. Here you would see all applications in Spaces your user is a member of

### <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Deploy an Application
1. Click on the **+** button in the header

1. Click on **Public GitHub** 

1. Select
  - **{{cf-endpoint-name}}** as your Cloud Foundry
  - **cf-summit** as your organisation 
  - **stratos-{{seat}}** as your space

1. Click **Next**

1. For you project enter 
   ```
   cf-stratos/cf-quick-app
   ```

1. Click **Next**

1. In the next step leave the first commit selected 

1. Click **Next**

1. Override the **Application Name** in the **General** section as follows
   ```
   {{seat}}-my-cf-quick-app
   ```

1. Create a random route by checking the for **Create a random route** in the **Route** section

1. Click **Deploy** to kick it off

1. Wait for the Deployment to complete 
   - The top of the log should contain an overlay stating **Deployed**
   - The below line should be shown at the end of the log

     **#0   running   <current date>   0.0%   0 of 16M   0 of 64M**

1. Click on **Go to App Summary** and explore the Application functionality provided by Stratos, including those in the sub-sidenav

## Summary
We hoped you've enjoyed this hands on. You should now have an understanding of how to...

- Install Stratos via Kubernetes
- Create and connect to Stratos Endpoints, including Kubernetes, Helm and Cloud Foundry
- View Kubernetes information in Stratos, including Workloads
- Browse and install Helm charts
- Browse and deploy CF Applications

If you would like to know more about Stratos please reach out to us via our [GitHub Repo](https://github.com/cloudfoundry/stratos) or directly in the Cloud 
Foundry [#stratos](https://cloudfoundry.slack.com/?redir=%2Fmessages%2Fstratos) room.

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy> 
