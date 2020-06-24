## Gluon Hands-On Lab

In this hands-on lab, we will be exploring the dynamic duo of BOSH
and Kubernetes, via the open source **Gluon** controller, and its
custom resource definitions.  With Gluon, you will be able to
manage BOSH things like cloud-configs, stemcells, and deployments,
from the comfort of your Kubernetes cluster.

We will be using a GKE cluster with the Gluon controllers already
installed, and a BOSH director spun up and ready for deployments.

### Target Audience

This lab is geared towards BOSH operators who would like to
investigate a Kubernetes-first approach to traditional deployments
like VM-based Cloud Foundry.

### Learning Objectives

We will cover the following topics:

  - The Gluon object pipeline
  - Gluon dependencies
  - The use of Kubernetes Jobs

You will perform the following tasks:

  - Connect to the BOSH director using the `gluon` CLI
  - Enumerate the environment (stemcells, cloud-configs, etc.)
  - Deploy a single-node Vault instance

### Prerequisites

You should be familiar with BOSH and Kubernetes concepts (Pods,
Directors, Deployments, etc.), and be comfortable with the `bosh`
and `kubectl` command-line tools.

## Seat Assignments

Each participant in this lab will be assigned a unique seat
assignment by one of the lab proctors.  Each seat is numbered from
100 to 199, and everything you do will be tagged with your seat
number to ensure we aren't stepping on each others toes.

Once you have your number, run the following:

    source seat

You can verify your seat assignment at any time by running:

    ./seat

## Setting up Cloud Shell

This lab requires that the `bosh` and `gluon` utilities be
installed in your lab environment.

### BOSH Tooling

First, we'll install `bosh`:

    curl -Lo bosh https://github.com/cloudfoundry/bosh-cli/releases/download/v6.3.0/bosh-cli-6.3.0-linux-amd64
    chmod 755 bosh
    sudo mv bosh /usr/bin

### Gluon Tooling

Next, we'll install `gluon`:

    curl -Lo gluon https://raw.githubusercontent.com/starkandwayne/gluon/master/bin/gluon
    chmod 755 gluon
    sudo mv gluon /usr/bin

### Targeting the Kubernetes Cluster

Now we need to connect to the GKE cluster that is running the
Gluon controller, so we can explore:

    gcloud container clusters get-credentials gluon-lab-cluster-1 \
      --zone us-east1-c --project summit-labs

All of our work will be done in the `proto` Kubernetes namespace.
You should not need to interact with any other namespaces, so
we'll set up your `kubectl` accordingly:

    kubens proto

## Gluon Concepts and the Lab Environment

Gluon is implemented as three custom resource types, and a
Kubernetes controller to manage and react to them.

### BOSHDeployment

A `BOSHDeployment` represents a set of one or more VMs that we
want BOSH to deploy for us.  Gluon can handle both `bosh create-env`
and `bosh deploy` deployments.

We've already deployed a BOSH director for you, called `proto`.
An approximation of the `BOSHDeployment` resource we created for
that can be found in the `director.yml` file.

    cloudshell edit director.yml

Read through the comments in that file to get a feel for how
manifests can be managed via Kubernetes.

### BOSHStemcell

A `BOSHStemcell` lets you specify which stemcells you want to
exist on which BOSH directors, and let Gluon handle the when and
how of doing the uploads.

We've already uploaded a Xenial stemcell to our `proto` BOSH
director, but to see how we did it, look at the `stemcell.yml`
file:

    cloudshell edit stemcell.yml

(as the comments point out, please don't apply these YAML files.)

### BOSHConfig

A `BOSHConfig` represents configuration, either for
injecting runtime addons (a "runtime" config) or for specifying
IaaS-specific configuration (a "cloud" config).

We've already applied a cloud config to our `proto` BOSH director.
You can see that config by reviewing the `cloud-config.yml` file:

    cloudshell edit cloud-config.yml


## Explore The `proto` BOSH Director

Before we can deploy something, we need to know where the BOSH
director is.  We can get all of that information out of
Kubernetes.

First, list the `BOSHDeployment`, `BOSHStemcell`, and `BOSHConfig`
resources that have already been defined:

    kubectl get boshdeployment,boshstemcell,boshconfig

(you can safely ignore the `vault-199` deployment, that belongs to
the lab proctors.)

Review the installation log for the `proto` director:

    kubectl logs $(pod deploy-proto-bosh)

When Gluon finishes deploying a BOSH director via `bosh
create-env`, it extracts key pieces of information from the output
vars-store and persists those to a secret.

Review the (base64-encoded) BOSH credentials:

    kubectl describe secret proto-secrets

Check the BOSH environment URL, username, and password:

    kubectl get secret proto-secrets -o template='{{.data.endpoint | base64decode}}'; echo
    kubectl get secret proto-secrets -o template='{{.data.username | base64decode}}'; echo
    kubectl get secret proto-secrets -o template='{{.data.password | base64decode}}'; echo
    echo

We can use this, setting the environment variables the `bosh`
expects to see, and validate that the director is working:

    BOSH_CLIENT=$(kubectl get secret proto-secrets -o template='{{ .data.username | base64decode }}') \
    BOSH_CLIENT_SECRET=$(kubectl get secret proto-secrets -o template='{{ .data.password | base64decode }}') \
    BOSH_CA_CERT=$(kubectl get secret proto-secrets -o template='{{ .data.ca | base64decode }}') \
    BOSH_ENVIRONMENT=$(kubectl get secret proto-secrets -o template='{{ .data.endpoint | base64decode }}') \
      bosh env

## Using the `gluon` CLI

In the last section, we used a bunch of (complicated!) `kubectl`
invocations to set environment variables so that we could run BOSH
commands.

Gluon ships with a small command-line utility that makes this much
easier:

    gluon @proto env

Wherever you would type `bosh`, type `gluon @proto` instead, and
Gluon will do what you intend -- you can run any BOSH command!

List the stemcells that have been uploaded:

    gluon @proto stemcells

Look at the defined cloud- and runtime-configs:

    gluon @proto configs

Review the cloud-config that we're about to use to deploy Vault:

    gluon @proto cloud-config

Find out what (if anything) has been deployed to the `proto` BOSH
director:

    gluon @proto deployments


## Deploying Vault

Now we're going to use Gluon, and our Kubernetes cluster, to
deploy a single-node Vault deployment to GCP via the `proto` BOSH
director.  This Vault will come with a UI, and we've set up
routing to get from the public internet to the per-seat endpoints
you're each about to deploy.

In fact, to show you what we're going to do, we've gone ahead and
taken seat #199 and deployed it for you -- indeed you may have
seen it in the `bosh deployments` output already.  You can access
this vault by pointing your web browser at
<https://vault199.hol.gluon.starkandwayne.com>.

![Vault 199's Web User Interface (screenshot)](https://github.com/cloudfoundry/summit-hands-on-labs/raw/master/na-2020/gluon/.assets/vault199.png)

That's what yours is going to look like.

### Crafting the YAML

In the root of this repository, in your Google Cloud Shell
environment, you'll find a file called `vault.yml`.  It contains
_most_ of a Gluon BOSHDeployment for spinning our Vault.  You'll
need to replace all occurrences of the string `[seat]` with your
seat number (as assigned by the lab proctors), before you can
deploy it.

To edit the file, open it up in the Cloud Shell Editor:

    cloudshell edit vault.yml

Then, replace every instance of `[seat]` with your seat
assignment.  If you've forgotten your seat assignment, just run
`./seat` from the shell.

### Applying the YAML

Once you've modified the `vault.yml` file, you can validate it and
deploy it:

    validate && kubectl apply -f vault.yml

(If `validate` kicks out warnings about unreplaced `[seat]`
references, be sure to fix those and try the above command until it
succeeds.)

### Watching the Jobs 'n' Pods

Gluon should react to your new BOSHDeployment resource by creating
a Job to deploy your manifest to the BOSH director.  Kubernetes'
built-in controllers should (in turn) create a Pod to actually
execute on the Job's configuration.

Review the job:

    kubectl get job deploy-vault-$SEAT-via-proto

Review the pod:

    kubectl get pod $(pod deploy-vault-$SEAT)

Tail the log of the deployment job pod:

    kubectl logs -f $(pod deploy-vault-$SEAT)

### Validating via Gluon 'n' BOSH

While the Vault is deploying, you can also check the BOSH director
(using the `gluon @proto` syntax) for your deployment, and can
follow the deployment task using BOSH tooling, if you desire.

First, check the deployments list for your Vault:

    gluon @proto deployments | grep vault-$SEAT

Check the BOSH tasks for your deployment (if it is still ongoing):

    gluon @proto -d vault-$SEAT tasks --recent=1

Finally, check the task log (by task ID, above):

    gluon @proto task TASK-ID


### Visiting your Vault on the Web

Once your Vault is deployed, you should be able to access it via
its public web URL, which you can find by running `./seat` again:

    ./seat

Google Cloud Shell should allow you to click on the link to your
Vault and open it up in a new browser tab or window.  Remember: we
are using a self-signed certificate in this lab, so you will need
to accept the security warning and proceed anyway.

## Congratulations!

You did it!


### Beyond the Lab

Did you enjoy that?  Want to get more involved in Gluon?
Here's some resources!

- **Gluon Homepage** - <https://starkandwayne.com/gluon>
- **Gluon @GitHub** - <https://github.com/starkandwayne/gluon>
