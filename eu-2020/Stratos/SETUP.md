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
   ./setup-env.sh && source user-env
   ```

   The script will 
   - install the `helm` CLI and configure it and `kubectl` to communicate with your own Kube Cluster that we have assigned to your user.
   - create a Service Token that Stratos will use to communicate with the cluster.
   - update and reload the tutorial

   Ensure that the script completes successfully, it should print `Set up complete`


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

