## Introduction

In this hands on lab, you will deploy a simple web application on Kubernetes cluster using `cf push` command.

The bridge between `cf push` and Kubernetes is filled by cf-operator and SCF. With cf-operator & SCF, you need not worry about designing how to deploy your application on Kubernetes. You need not care about networking, scaling, zone management, B/G deployment and routing which are not available in Kubernetes.

Simply put, cf-operator enables Kubernetes as a Paas platform using Cloud Foundry templated style workflow. It enables Cloud Foundry developer experience on Kubernetes.

## Target Audience

This lab is targeted towards the audience who would like to use cloud foundry for packaging and deploying applications and Kubernetes as the underlying infrastructure for orchestration of the containers.

## Learning Objectives

* Install cf-operator on Kubernetes.
* Install SUSE Cloud Foundry (SCF) on cf-operator.
* Deploy an app on Kubernetes cluster using cf-push.
* Curl the app to check if it is deployed correctly.

## Prerequisites

Students must have basic knowledge of Cloud Foundry, Kubernetes.

## Lab

### Using the CLI

You will have access to `kubectl` and `helm` in the CLI.

* Kubectl is a command line interface for running commands against Kubernetes clusters.
* Helm is a command line tool for managing Kubernetes application. used for installing cf-operator and SCF on Kubernetes.

### Authenticate

To work with Kubernetes you need a valid `KUBECONFIG`. The following commands will acquire a config from Google Cloud.
Your cloud shell account contains a number from 1 to 10, to which we refer as *[seat]* throughout the instructions.

```
clustername=hol-cluster-[seat]
gcloud container clusters get-credentials "$clustername" --zone europe-west4-a --project phillyhol
```

To check if the connection was successful run

```
kubectl version
helm version
```

If you can see client and server versions for both the commands, then you are good to go ahead.


### Installing cf-operator

The `cf-operator` is packaged as a helm release. Run the following command to install `cf-operator` in a namespace:

```
helm install --namespace scf --name cf-operator \
  --set "provider=gke" \
  https://s3.amazonaws.com/cf-operators/release/helm-charts/cf-operator-v0.4.0%2B1.g3d277af0.tgz
```

Run the following command to check if the cf-operator pod is in running status.

```
kubectl get pod -n scf
```

#### Troubleshooting

If you want to install again, use the `--set "customResources.enableInstallation=false"` flag for helm and delete the webhook configuration first:

```
kubectl delete mutatingwebhookconfiguration "cf-operator-hook-cf-operator"
kubectl delete validatingwebhookconfiguration "cf-operator-hook-cf-operator"
```

### Installing SCF

`SCF` is also packaged as a helm release. Run the following command to install `scf` in the same namespace:

```
helm install --namespace scf --name scf https://scf-v3.s3.amazonaws.com/scf-3.0.0-8f7a71d1.tgz --set "system_domain=scf.suse.dev"
```

This installation takes about 15 minutes. Run the following command to watch untill all the scf pods have status as Running.

```
watch kubectl get pods -n scf
Press Ctrl+C to quit
```

### Pushing an App

Pushing an app into kubernetes using Cloud Foundry tools requires access to Cloud Foundry CLI. Run the following command to deploy a pod which contains CLI.

```
bash cf-cli.sh
```

Check the status of the pod with name starting with `cf-terminal` using

```
kubectl get pod -n scf | grep "cf-terminal"
```

We need to ssh into the pod to use the CLI. Copy the pod name from the above command and run the following to ssh into the pod.

```
podname=${podname}
kubectl -n scf exec -it ${podname} -- /bin/bash
```

Check if you have access to `cf` command. Run 

```
cf version
```

Now, execute the following commands to push an app using CLI.

```
cd cf-hello-worlds/python-flask
cf push app1
```

Check if it is successfully deployed.

```
curl https://app1.scf.suse.dev -k
```

So, you have successfully deployed an application into kubernetes using all the magical features from CF !!!

### Debugging K8S

CF Operator logs:

```
export OPERATOR_POD=$(kubectl get pods -l name=cf-operator --namespace cf-operator --output name)
kubectl -n cf-operator logs $OPERATOR_POD -f
```

## Beyond the Lab

* Checkout project Quarks on Github : https://github.com/cloudfoundry-incubator/cf-operator
* Checkout project SCF on Github    : https://github.com/SUSE/scf
