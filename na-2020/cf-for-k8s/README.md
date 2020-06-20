## Introduction

In this hands on lab, attendees will learn how to deploy Cloud Foundry on a Kubernetes (cf-for-k8s) project to a Kubernetes cluster, push cf push apps, deep dive into cf push workflow, inspect various cluster resources created by cf-for-k8s. We will also peek into upcoming new features and how they fit into the operator and app developer experience.

### Target Audience

This lab is targeted towards the audience who would like to use Cloud Foundry for packaging and deploying cloud native applications with Kubernetes as the underlying infrastructure.

## Learning Objectives

You will be performing the following tasks in this lab :-

- Install cf-for-k8s
- Inspect app workloads, routing and logging
- Upgrade cf-for-k8s
- Delete cf-for-k8s
- Using overlays with `ytt`

## Prerequisites

Students must have basic knowledge of Cloud Foundry and Kubernetes.

## Lab

### Setup cluster 

1. We will use your user-id to retrieve your alloted Kubernetes cluster. It should be in the form `N-summitlabs@cloudfoundry.org` where `N` is an integer. We will use the value before the email domain (e.g. `1-summitlabs`, `2-summitlabs` and so on),
    ```console
    export SEAT=<your-seat-number>-summitlabs
    ```
1. Export your $CF_DOMAIN using your seat number,
    ```console
    export CF_DOMAIN=$SEAT.cf-for-k8s-labs.com
    ```
1. Lets setup your `kubectl` so you connect to your alloted Kubernetes Cluster
    ```console
    gcloud container clusters get-credentials \
        "$SEAT-cf-for-k8s-cluster" --zone us-west1-a \
        --project summit-labs
    ```
1. Verify that you are connected and have all the necessary CLI's

    ```console
    kubectl version
    kapp version
    ytt version
    bosh --version
    cf version
    ```
    If any of the CLIs are not installed, please see the Troubleshooting guide - Install missing CLIs section

    > Note we are using bosh CLI to only generate self-signed certificates. It is a matter of convenience and in the future it will be replaced by tooling like CredHub

### Installing cf-for-k8s

1. Clone cf-for-k8s project into the current directory
    ```console
    git clone git@github.com:cloudfoundry/cf-for-k8s.git
    cd cf-for-k8s
    ```
1. Create a data values file with required values to install cf-for-k8s project

    We will use script `generate-values.sh` to generate these values to make the labs session go faster.
    ```console
    ./hack/generate-values.sh -d $CF_DOMAIN > cf-values.yml
    ```
    > This script is the only script that uses the `bosh-cli` to generate the self-signed cerficiates and random passwords.
1. To be able to push source code apps, we need to setup a docker registry. We pre-created a `labs-values.yml` file for you to use in the labs,
    ```console
    cat ../labs-values.yml >> cf-values.yml
    ```
    > The command appends docker registry configuration to your `cf-values.yml`. Don't forget to check it out later.
1. Render the final k8s configuration yml using `ytt` command
    ```console
    ytt -f config -f cf-values.yml > cf-for-k8s-rendered.yml
    ```
1. Install with `kapp` with above K8s configuration file
    ```console
    # deploy cf-for-k8s named `cf`
    kapp deploy -a cf -f cf-for-k8s-rendered.yml -y
    ```
    Once you press enter, the command should take ~8-10 minutes to finish. During this time, `kapp` will keep posting updates on pending resource creations and will exit only when all resources are created and running.
1. Verify the install is ready to connect CF CLI
    ```console
    cf api --skip-ssl-validation https://api.$CF_DOMAIN
    ```
1. Login using the admin credentials in `cf-values.yml`
    ```console
    cat cf-install-values.v52.yml| grep cf_admin_password
    # should print `cf_admin_password: <admin password>`
    cf auth admin <admin password>
    ```
1. Create an org/space for your app
    ```console
    # following creates org, space and then targets org and space all in one command
    cf co labs-org && cf target -o labs-org && cf create-space labs-space && cf target -o labs-org -s labs-space
    ```
1. Deploy a source code based app
    ```console
    # pushes 2 instances of the node app
    cf push test-app -i 2 -p ./tests/smoke/assets/test-node-app/
    ```
    Watch the logs to see your source code tranform to an actual running app. High level steps worth noting are,

    1. push app source code from directory to the blobstore
    1. run through a detection to identify the app language
    1. pull the necessary base images for the given language (in this case `Node Engine Buildpack`)
    1. build the app image with the above base image 
    1. create a HTTP route to the app
    1. schedule the app with the given # of instances
    1. report the app status and any metrics
1. Verify app reachability!!
    ```console
    curl -k https://node-app.apps.$CF_DOMAIN
    ```
1. Few additional CF commands
    ```console
    cf app node-app
    cf logs --recent node-app
    cf routes
    ```

### Inspecting the cluster

1. App pods
    ```console
    kubectl get pods -n cf-workloads
    ```
    Notice the the 2 pods created in the `cf-workloads` namespace (more on namespaces in the next coming sections). The # of pods correspond to the # of instances of the app you specified above (`-i 2`).
1. App route services
    ```console
    kubectl get svc -n cf-workloads
    # should print
    NAME                TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
    <service-guid>      ClusterIP   10.0.9.52    <none>        8080/TCP   39m
    ```
    For every app route, cf-for-k8s creates route CRD and a Kubernetes native `Service` that serves the app instances. Lets look underneath the service. 
    ```
    kubectl describe svc/<service guid from the above> -n cf-workloads
    ```
    Notice the `Annotations` property and `route-fqdn` value. It is the same URL that you used to access the app above.
    1. Lets create another route to see what happens
        ```console
        cf map-route node-app --hostname node-another-app apps.$CF_DOMAIN
        ```
        You should now see 2 services
        ```console
        kubectl get svc -n cf-workloads
        # should print
        NAME                TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
        <service-guid-1>      ClusterIP   10.0.9.52    <none>        8080/TCP   39m
        <service-guid-2>      ClusterIP   10.0.9.52    <none>        8080/TCP   2secs
        ```
        Pick the new `service` that was created recently and inspect it's `Annotations.route-fqdn` property.
        ```
        kubectl describe svc/<name of the service guid from the above> -n cf-workloads |  grep Annotations 
        ```
    1. Verify route CRDs
        ```
        kubectl get routes -n cf-workloads
        ```
        Notice two routes under the `cf-workloads` namespace.

    To summarize, for every app route there exists a `route` CRD that maps to a Kubernetes `service`.

1. Ingress gateway
    To access the app from external network, you still need a mechanism to connect the incoming traffic to the right app `service`. This is where the ingress gateway plays the role of traffic director.
    ```console
    kubectl get gateway -n istio-system
    ```
    The gateway responsible for directing the traffice to the apps or CF API. The domain you setup above is fed into the gateway as the allowed hostnames.
    ```console
    kubectl describe gateway/ingressgateway -n istio-system
    ```
1. Staging apps
    As you noticed, cf-for-k8s builds an OCI compliant image from your source code. Let's inspect the pods who are responsible to build those images,
    ```console
    kubectl get pods -n cf-workloads-staging
    ```
    There should be a single build pod with the status `Completed` in the `cf-workloads-staging` namespace. This pod was used to build the app image from source and then push the image to the docker registry (We configured the registry in `labs-values.yml` file when we installed cf-for-k8s).
    ```console
    kubectl describe pod/<pod-guid> -n cf-workloads-staging | grep Events -A 20
    ```
    Notice the events that it emits during build stage. You probably saw them during `cf push` streaming logs above. In the next section, we will take a closer look at the language buildpacks.
1. App language detection
    During `cf-push`, the source code goes through detection phase, where it finds the right language buildpack base image to build the app from source code.
    ```console
    kubectl describe stores/cf-buildpack-store | grep "Buildpackage" -A 10
    ```
    The above command shows a list of language buildpacks that are supported. We are integrating the new rebranded paketo buildpacks which are based on the cloud native buildpack spec.

    ```console
    kubectl describe stores/cf-buildpack-store | grep Order: -A 20 | grep node -B 5 -A 5
    ```
    The above command highlights the detection ordering within the node language buildpackage. You may have noticed it during `cf push` logs.
1. Control plane
    The control plane components are stored in `cf-system` namespace
    ```console
    kubectl get pods -n cf-system
    ```
    Notable pods are the CAPI component that backs the cf cli, uaa manages authentication, logs and metrics for observability, eirini schedules & manages the app workloads and finally route-controller manages the app routes. Also, Notice `fluentd` pods in `cf-system`. It's actually a deamon-set that's running on every node to collect and filter logs for CF.
1. Namespaces created by cf-for-k8s
   ```console
    kubectl get namespaces
   ``` 
    It will return 7 namespaces that were created by cf-for-k8s (rest are namespaces created by GKE). Inspect each namespace by running 
    ```console
    kubectl get pods -n <namespace>
    ```
    
    `cf-db` and `cf-blobstore` namespaces run postgres database and minio blobstore stateful-sets respectively. `kpack` namespace holds kpack controller which is responsible for building, packaging and pushing the app images to the docker registry (see Staging apps and App lang detection sections above).

    `istio-system` holds istio control plane components. Istio is responsible for ingress gateway, gateway encryption and setup encrypted communication between between components - aka the service mesh. 

    > `istio` injects side-cars into pods deployed by cf-for-k8s, which encrypts all communication between the containers running on the pod and other pods in the cluster (who are also running the side-car. The side-car injection is enabled at namespace level, so every pod within the namespace is injected with a side car. 

    ```
    # should display the flag `istio-injection=enabled`
    kubectl describe ns/cf-db | grep istio-injection 
    ```

### Upgrade cf-for-k8s
In this excercise, we will upgrade the existing foundation [TODO]

[TODO]

### Using overlays with `ytt`
In this excercise, update default app memory and disk in capi config using overlay.

1. Create the a yaml called `update-default-app-memory-and-disk.yaml` in `/config-optional` folder

```console
$ touch config-optional/update-default-app-memory-and-disk.yaml
```

1. Open the `update-default-app-memory-and-disk.yaml` and copy the following contents

```console



```

1. `ytt` generate with the above config, `kapp` deploy to the existing foundation
1. verify by re-pushing the app shows the memory/app

## Learning Objectives Review

## Beyond the Lab

## Troubleshooting guide 

### Install missing CLIs
1. To install `ytt`, `kapp`
    ```console
    curl -L https://k14s.io/install.sh | bash
    ```
1. To install `cf` cli
1. To install `bosh` cli
    ```console
    wget https://github.com/cloudfoundry/bosh-cli/releases/download/v6.3.0/bosh-cli-6.3.0-linux-amd64
    ??
    ```