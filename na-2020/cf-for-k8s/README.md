## Introduction

In this hands on lab, attendees will learn how to deploy Cloud Foundry on a Kubernetes (cf-for-k8s) project to a Kubernetes cluster, push source code apps, deep dive into cf push workflow, inspect various cluster resources created by cf-for-k8s. 

We will also peek into upcoming new features and how they fit into the operator and app developer experience.

### Target Audience

This lab is targeted towards the audience who would like to use Cloud Foundry for packaging and deploying cloud native applications with Kubernetes as the underlying infrastructure.

### Learning Objectives

You will be performing the following tasks in this lab :-

- Install cf-for-k8s
- Inspect app workloads, routing and logging
- Using overlays with `ytt`
- Delete cf-for-k8s

### Prerequisites

Students must have basic knowledge of Cloud Foundry and Kubernetes.

## Setup Environment

Let's setup your environment by running the followign command in your console.

```console
eval "$(./setup-env.sh)"

```

The script will install cf-cli, k14s tools (`ytt`, `kapp`) plus few other helpful tools for the lab session. 

The script also setups up your `kubeconfig` by connecting to an existing k8s cluster. 

We are using bosh CLI to generate self-signed certificates and other credentials. It is a matter of convenience and in the future it will be replaced by tooling such as CredHub.

### Verify CLIs exists

```console
cf version
ytt version
kapp version

```

### Verify connection with K8s cluster
```console
kubectl get namespaces

```
  
## Clone project

Clone the cf-for-k8s project from the source repository.

```console
git clone https://github.com/cloudfoundry/cf-for-k8s.git
cd cf-for-k8s

```

## Create a values file

Lets create a values file using the convenient script `generate-values.sh`. Copy and paste the following command in your console.

```console
./hack/generate-values.sh -d $CF_DOMAIN > cf-values.yml
cat<<EOF >> cf-values.yml
istio_static_ip: "$(host api.${CF_DOMAIN} | awk '{print $NF}')"
EOF

```
- `generate-values.sh` generates the necessary self-signed certificates and credentials using bosh cli.
- Sets the Kubernetes loadbalancer IP to reserved IP that comes with the lab session. It reduces overall time to install the cluster.

### Setup docker registry
Before we can push source code apps, we need to setup a docker registry. We pre-created a `labs-values.yml` file for you to use in the lab.

 ```console
 cat ../labs-values.yml >> cf-values.yml
 
 ```

The above command appends the docker registry configuration to your `cf-values.yml`. Don't forget to check it out later.

## Render with ytt
Render the final k8s configuration yml using `ytt` command

```console
ytt -f config -f cf-values.yml > cf-for-k8s-rendered.yml

```

## Install with kapp

Let's now install cf-for-k8s using `kapp` command

 ```console
 kapp deploy -a cf \
    -f cf-for-k8s-rendered.yml -y
 
 ```

Once you press enter, the command should take about ~8-10 minutes to finish. During this time, `kapp` will keep posting updates on pending resource creations and will exit only when all resources are created and running.

## Connect to CF CLI
Verify that you can connect to the foundation using CF CLI

```console
cf api --skip-ssl-validation https://api.$CF_DOMAIN

```

## Login to CF
Login using the admin credentials in `cf-values.yml`

```console
 cf auth admin $(yq -r .cf_admin_password cf-values.yml)
 
 ```

## Create org/space for your app
Next, create orgs and spaces

```console
cf create-org labs-org
cf create-space -o labs-org labs-space
cf target -o labs-org -s labs-space

```

## Deploy the source code app

Finally, lets push our app. Pay particular attention to the logs to see the various steps it goes to detect, build and run the app.

```console
cf push node-app -i 2 -p ./tests/smoke/assets/test-node-app/

```
### Watch the logs

Notice how your source code is tranformed to an actual running app. High level steps worth noting are,

1. push app source code from directory to the blobstore
1. run through a detection to identify the app language
1. pull the necessary base images for the given language (in this case `Node Engine Buildpack`)
1. build an **OCI compliant** app image with the above base image
1. Push the app image to the registry
1. create a HTTP route to the app
1. schedule the app with the given # of instances
1. report the app status and any metrics

## Curl the app
The final moment we have been waiting for. 
```console
curl -k https://node-app.apps.$CF_DOMAIN

```

Congratulations!! You have done it. 

### Checkout other CF commands

### Lets see app status 
```console
cf app node-app

```
### what about logs
```console
cf logs --recent node-app

```
### Also, check out routes
```console
cf routes

```

Next, we will go on a journey to understand how an app is actually deployed, how it is built, components that are involved in creating the app and so on. Lets start!!!

## Inspecting App pods
First, lets look at our apps. The app is actually deployed to `cf-workloads` namespace (more on namespaces in the next coming sections). Run the command to see the pods.

```console
kubectl get pods -n cf-workloads

```
Notice that there are 2 pods. The # of pods correspond to the # of app instances that you specified above (`-i 2`) during `cf push`.

## Inspecting App route services
For every app route, cf-for-k8s creates route CRD and a Kubernetes native `Service` that serves the app instances. Lets see the services of the app.

```console
kubectl get svc -n cf-workloads

```
Now, lets look at the service itself. Pick the service guid from the above and replace the `<service guid>` below.

```console
kubectl describe svc/<service guid> -n cf-workloads

```
Notice the `Annotations` property and `route-fqdn` value. It is the same URL that you used to access the app above.

### Create another route for the same app
Lets create another route to see what happens
```console
cf map-route node-app --hostname node-another-app apps.$CF_DOMAIN

```
You should now see 2 services

```console
kubectl get svc -n cf-workloads

```
Pick the `Service` that was created recently and replace the `<service guide>` in the command below. Inspect it's ouput `Annotations.route-fqdn` property. Notice the URL you just created.

```console
kubectl describe svc/<name of the service guid from the above> -n cf-workloads |  grep Annotations

```
The `route-controller` is responsible for creating the `route` CRD, which in turn creates the actual k8s `Service`

```console
kubectl get routes -n cf-workloads

```
Notice two routes under the `cf-workloads` namespace.

To summarize, for every app route there exists a `route` CRD that maps to a Kubernetes `service`.

## Inspect Ingress gateway
To access the app from external network, you still need a mechanism to connect the incoming traffic to the right app `service`. This is where the ingress gateway plays the role of traffic director.
    
```console
kubectl get gateway -n istio-system

```
The gateway is responsible for directing the traffice to the apps or CF API. The domain you setup above is fed into the gateway as the allowed hostnames.

```console
kubectl describe gateway/ingressgateway -n istio-system

```

## Building the image
As you noticed, cf-for-k8s builds an OCI compliant image from your source code. Let's inspect the pods who are responsible for creating the app images.

```console
kubectl get pods -n cf-workloads-staging

```
    
There should be a single build pod with the status `Completed` in the `cf-workloads-staging` namespace. This pod was responsible for creating the app image from source and then pushing the image to the docker registry (which we configured in `labs-values.yml` file when we installed cf-for-k8s).
```console
kubectl describe pod/<pod-guid> -n cf-workloads-staging | grep Events -A 20

```

Notice the events that it emits during build stage. You probably saw them during `cf push` streaming logs above. In the next section, we will take a closer look at the language buildpacks.

## Buildpacks

During `cf-push`, the source code goes through detection phase, where it finds the right language buildpack base image to build the app from source code.
```console
kubectl describe stores/cf-buildpack-store | grep "Buildpackage" -A 10

```

The above command shows a list of language buildpacks that are supported. We are integrating the new rebranded paketo buildpacks which are based on the cloud native buildpack spec.

```console
kubectl describe stores/cf-buildpack-store | grep Order: -A 20 | grep node -B 5 -A 5

```
The above command highlights the detection ordering within the node language buildpackage. You may have noticed it during `cf push` logs.

## Stacks
Apps need root file system to run. A stack provides the buildpack lifecycle with build-time and run-time environments in the form of images. You can see what stacks are installed in `cf-workloads` namespace.

```console
kubectl get stacks -n cf-workloads-staging

```

```console
kubectl describe stacks/cflinuxfs3-stack -n cf-workloads-staging | grep Spec -A 6

```
Notice the build and run image entries. In most cases, both are same images.


## Control plane components
The control plane components are stored in `cf-system` namespace
```console
kubectl get pods -n cf-system

```

Notable pods are the CAPI component that backs the cf cli, uaa provides authentication and authorization sevices, logging and metrics components provide observability, eirini is responsible for scheduling & managing the app workloads and finally route-controller is responsible for the app routes. 

Also, Notice `fluentd` pods in `cf-system`. It's actually a deamon-set type that's running on every node to collect and filter logs for CF.

## Inspect namespaces

```console
kubectl get namespaces

```
It will return 7 namespaces that were created by cf-for-k8s (the rest are namespaces created by K8s).

### Statefulsets

```console
kubectl get pvc -n cf-db
kubectl get pvc -n cf-blobstore

````

`cf-db` and `cf-blobstore` namespaces run postgres database and minio blobstore stateful-sets respectively. 

### kpack

`kpack` namespace holds kpack controller which is responsible for building, packaging and pushing the app images to the docker registry (see Staging apps and App lang detection sections above).


### Istio

```console
kubectl get pods -n istio-system

````

`istio-system` holds istio control plane components. Istio is responsible for ingress gateway, ingress encryption and encrypted communication between components - aka the service mesh.

`istio` injects side-cars into pods deployed by cf-for-k8s, which encrypts all communication between the containers running on the pod and other pods in the cluster (who are also running the side-car. The side-car injection is enabled at namespace level, so every pod within that namespace is injected with a side car.

```console
kubectl describe ns/cf-system | grep istio-injection

```

Check out the side car proxy in a CAPI pod.

```console
kubectl get pods -n cf-system | grep cf-api-server
```
Pick any one pod from the above and replace `<pod id>` and run the command,
```
kubectl describe pod/<pod id> -n cf-system | grep "istio-proxy:" -A 5 -B 5
```

Notice the `istio-proxy` is a container running along side the `cf-api-server`


## Using overlays with `ytt`
In this excercise, we will scale the control plane apps using a `ytt` overlay. `ytt` is a very powerful yml templating tool and cf-for-k8s uses ytt extensively. 

Assuming you're still in `cf-for-k8s` folder, run the following command,

```console
ytt -f config -f ../scale-cluster.yml -f ../scale-cluster-data-values.yml -f cf-values.yml > cf-for-k8s-rendered.yml
```





## Learning Objectives Review

## Beyond the Lab

## Troubleshooting guide
