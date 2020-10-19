## Set up your personal environment

Welcome to your GCS Session. The rest of the tutorial can be done in this environment and one other browser tab.

In this step we will set up some CLI tools and test them.


<!--
// TODO:
### Authorise Google Cloud Shell with Google Compute API
1. Allow your session user to access the required APIs by clicking on the button below and accepting the permissions

   <walkthrough-enable-apis apis="compute.googleapis.com">Enable the Compute API</walkthrough-enable-apis>

   Alternatively enable APIs from the command line with:

   ```bash
   gcloud services enable compute container compute.googleapis.com --project summit-labs
   ``` -->
### <walkthrough-cloud-shell-icon></walkthrough-cloud-shell-icon> Install Tools, Get Kube Credentials
1. Run the following script
   ```bash
   ./setup-env.sh && source user-env
   ```

   The script will 
   - install the `helm` CLI, and configure it and `kubectl` to communicate with your own Kube Cluster that we have assigned to your user.
   - create a Service Token that Stratos will use to communicate with the cluster.
   - create the environment variables needed to run through the tutorial
   - update and reload the tutorial
