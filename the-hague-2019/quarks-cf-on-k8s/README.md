## Introduction

In this hands on lab, you will deploy a simple web application on a Kubernetes cluster using cf push command.

In between Kubernetes and a `cf push` experience, we've added the CF Operator and SCF. You no longer need to design and implement your application deployment using complicated Kubernetes primitives. Networking, scaling, zone management, B/G deployment and routing are all managed for you.

Simply put, cf-operator enables Kubernetes as a PaaS platform using Cloud Foundry templated style workflow. It brings the Cloud Foundry developer experience to Kubernetes.

### Target Audience

This lab is targeted towards the audience who would like to use Cloud Foundry for packaging and deploying applications and Kubernetes as the underlying infrastructure for orchestration of the containers.

### Learning Objectives

* Install cf-operator on Kubernetes.
* Install SUSE Cloud Foundry (SCF) on cf-operator.
* Deploy an app on Kubernetes cluster using cf-push.
* Curl the app to check if it is deployed correctly.

### Prerequisites

Students must have basic knowledge of Cloud Foundry and Kubernetes.

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
```
```
gcloud container clusters get-credentials \
"$clustername" --zone europe-west4-a \
--project phillyhol
```

To check if the connection was successful run

```
kubectl version
helm version
```

If you can see client and server versions for both the commands, then you are good to go ahead.


## Installing cf-operator

The `cf-operator` is packaged as a helm release. Run the following command to install `cf-operator` in a namespace:

```
wget -O cf-operator https://s3.amazonaws.com/cf-operators/release/helm-charts/cf-operator-v0.4.0%2B1.g3d277af0.tgz
helm install --namespace scf \
  --name cf-operator \
  --set "provider=gke" \
  cf-operator
```

Watch the cf-operator pod untill it turns into running status.

```
watch kubectl get pod -n scf
```

### Troubleshooting

If you face an unknown error, re-install - delete the webhook secret, webhooks, helm cf-operator release using the following commands:

```
helm delete --purge cf-operator
kubectl delete mutatingwebhookconfiguration "cf-operator-hook-scf"
kubectl delete validatingwebhookconfiguration "cf-operator-hook-scf"
kubectl -n scf delete secret cf-operator-webook-server-cert
helm install --namespace scf --name cf-operator --set "provider=gke" --set "customResources.enableInstallation=false" \
  https://s3.amazonaws.com/cf-operators/release/helm-charts/cf-operator-v0.4.0%2B1.g3d277af0.tgz
```

## Installing SCF

`SCF` is also packaged as a helm release. Run the following command to install `scf` in the same namespace:

```
wget -O scf https://scf-v3.s3.amazonaws.com/scf-3.0.0-8f7a71d1.tgz
helm install --namespace scf --name scf \
scf \
--set "system_domain=scf.suse.dev"
```

This installation takes about 10 minutes. Run the following command to watch untill all the `SCF` pods have status as `Running`.

```
watch kubectl get pods -n scf
```

Press `Ctrl+C` to quit.

### Troubleshooting

If you want to re-install, delete the helm release and install it again.

```
helm delete --purge scf
kubectl delete ns scf-eirini
helm install --namespace scf --name scf \
https://scf-v3.s3.amazonaws.com/scf-3.0.0-8f7a71d1.tgz \
--set "system_domain=scf.suse.dev"
```


## Pushing an App

Pushing an app, requires a configured Cloud Foundry CLI. Run the following command to deploy a pod which contains the CLI.

```
bash cf-cli.sh
```

Check the status of the pod, whose name starts with `cf-terminal`, using

```
kubectl get pod -n scf | grep "cf-terminal"
```

We need to ssh into the pod to use the CLI. Run the below commands to ssh into the pod:

```
export podname=$(kubectl get pods -l app=cf-terminal --template '{{(index .items 0).metadata.name}}' -n scf)
kubectl -n scf exec -it "$podname" -- /bin/bash
```

Check if you have access to `cf` command. Run

```
cf version
```

Now, execute the following commands to push an app using the CF CLI.

```
cd cf-hello-worlds/python-flask
cf push app1
```

Check if it has been successfully deployed.

```
curl https://app1.scf.suse.dev -k
```

Exit the bash shell and run the following command to check the kubernetes pod, which is runnning your python web application, that was deployed using the CF CLI.

```
exit
```
```
kubectl get pods -n scf-eirini | grep app1
```

So, you have successfully deployed an application into Kubernetes using all the magical features from CF !!!

## Debugging K8S

CF Operator logs:

```
export OPERATOR_POD=$(kubectl get pods -l name=cf-operator --namespace cf-operator --output name)
kubectl -n cf-operator logs $OPERATOR_POD -f
```

### Beyond the Lab

* Checkout project Quarks on Github : https://github.com/cloudfoundry-incubator/cf-operator
* Checkout project SCF on Github    : https://github.com/SUSE/scf
