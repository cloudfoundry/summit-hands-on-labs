
## Introduction

In this hands on lab you will perform several tasks, using `KubeCF`, which is a containerized Cloud Foundry deployment on Kubernetes. `KubeCF` brings the developer experience of Cloud Foundry to Kubernetes in a production-ready environment. This time `KubeCF` is concentrated on `Eirni` features as `Erini` is now production ready in CAP v2.1.

### Target Audience

This lab is targeted towards an audience who would like to use Cloud Foundry for packaging and deploying applications with Kubernetes as the underlying infrastructure for container orchestration.

### Learning Objectives

You will be performing the following tasks in this lab :-

#### Tasks

* Push an application using `cf push` with `eirini` enabled instead of diego.
* Play around with `Eirni` and its extensions
    * SSH 
    * Persi
    * Logging
* Build your own EiriniX extension and deploy it.

### Prerequisites

Audience must have basic knowledge of Cloud Foundry and Kubernetes.

## Setup Environment

Let's set up your environment by running the following command in your console. 

    eval "$(./setup.sh)"

#### What it's doing

* The script will install cf-cli.
* The script also setups up your `kubeconfig` by connecting to an existing k8s cluster.
* Exports environment variables such as `$SEAT` and `$CLUSTER_NAME`.

### Verify CLIs exists

Running the following command will print versions for the CLI. 

    cf version

### Verify `KuebCF` pods

Run the following command to list the `Cloud Foundry` component pods deployed in `kubecf` namespace.

    kubectl get pods -n kubecf

* Your output should display all component pods with `Running` status.
* The `database-seeder-..` pod should be in `Completed` status.
* `KubeCF` is already installed for you using `helm`. 
* In case, you are interested to know how it is installed, you can checkout the steps from
[Installation Instructions](https://kubecf.io/docs/deployment/kubernetes-deploy/).

## Pushing an App

Pushing an app into `KubeCF`, requires a configured `Cloud Foundry CLI`. You shall now configure the CLI with the domain name `"eu$SEAT.kubecf.net"` which points to the installed KubeCF platform.

* Set the KubeCF API url.

        cf api --skip-ssl-validation \
        http://api.eu"$SEAT".kubecf.net

* Login using the user admin, so that you have full access to the `KubeCF` platform.

        admin_password=$(kubectl get secret \
        -n kubecf var-cf-admin-password \
        -o jsonpath="{.data.password}" | base64 --decode)
        cf login -u admin -p "${admin_password}"

* Create an organisation and space where you can push applications.

        cf create-org demo
        cf target -o demo
        cf create-space demo
        cf target -s demo

* Push an application into `KubeCF` platform using the `cf push` command

        git clone https://github.com/rohitsakala/cf-sample-app-python.git
        cd cf-sample-app-python
        cf push
 
 * Checkout if the app has been successfully deployed in the eirini namespace.
        
        kubectl get pods -n eirini

* Curl the url.

        curl http://python-flask-app.eu$SEAT.kubecf.net

OR

* Go to url in the browser. Make sure to replace the `$SEAT` variable with the number in your google email address.
    
        http://python-flask-app.eu$SEAT.kubecf.net

So, you have successfully deployed an application into KubeCF platform.

#### Troubleshooting

If you want to re-install, delete the app and retry the section.

        cf delete python-flask-app

## EiriniX Persi

In general, apps pushed into Cloud Foundry are ephermal and the data from the apps is not persisted. In any case, you would like to have your data persisted, you need to use the EiriniX Persi extension.

* A volume is needed where you can store the output from your application. In Cloud Foundry, service brokers are used to create services which includes getting storage capacity. So, we need to create a service broker.

        BROKER_PASS=$(kubectl get secrets -n kubecf -o json persi-broker-auth-password | jq -r '.data."password"' | base64 -d)

        cf create-service-broker eirini-persi admin $BROKER_PASS http://eirini-persi-broker:8999

* Enable access to all services of the broker.

        cf enable-service-access eirini-persi

* List plans available from the broker.

        cf marketplace -s eirini-persi

* Create a service which will provide us a volume.

        cf create-service eirini-persi default eirini-persi-volume -c '{"access_mode": "ReadWriteOnce"}'

* Check if the pvc is created.

        kubectl get pvc -n eirini

* Bind the service to the application.

        cf bind-service python-flask-app eirini-persi-volume

* Restage the app for a binding to work. 

        cf restage python-flask-app

* You can find the volume_mounts details in VCAP_SERVICES json.

        cf env python-flask-app

* Create a file in the volume by hitting this api endpoint.

        curl http://python-flask-app.eu$SEAT.kubecf.net/create

## EiriniX SSH

`cf ssh` doesn't work with Eirini. You need EiriniX SSH extension for the sub command to work. EiriniX SSH comes by default with `KubeCF` installation.

* You can ssh into the pushed application pod using 

        cf ssh python-flask-app

* Go to the mounted volume and check for the file created.

        export MOUNT_PATH=$(env | grep container_dir | cut -d":" -f2- | sed "s/,$//" | tr -d '"')
        ls $MOUNT_PATH

## EiriniX Logging

`cf logs` also doesn't work with Eirini. You need EiriniX Logs extension for the sub command to work. EiriniX Logs comes by default with `KubeCF` installation.

* You view the logs of the pushed application using 

        cf logs python-flask-app --recent

## Write your own EiriniX (Eirini extension)

You will be writing a security-oriented extension where you want to prevent Eirini apps from being pushed that doesn't pass a vulnerability scan.

For example, we could run [trivy](https://github.com/aquasecurity/trivy#embed-in-dockerfile) in an `InitContainer` and make the app pod crash before starting it up if tests fails.

* Setup go.mod for our project

First of all, create a new folder, and init it with your project path:

```$ go mod init github.com/user/eirini-secscanner```

At this point, we can run ```go get code.cloudfoundry.org/eirinix``` at the top level, so it gets added to go.mod.

You should have a go.mod similar to this one:

```golang
module github.com/[USER]/eirini-secscanner # NOTE: Replace [USER] with your username here

require (
	code.cloudfoundry.org/eirinix v0.3.1-0.20200908072226-2c03042398ea
	go.uber.org/zap v1.15.0
	k8s.io/api v0.18.6
	k8s.io/apimachinery v0.18.6
	k8s.io/client-go v0.18.6
	sigs.k8s.io/controller-runtime v0.6.2
)

go 1.14
```

### 2.2) Prepare GitHub repository

For easy of use, we will use GitHub to store our extension with git, and we will use github actions to build the docker image of our extension. In this way, we can later deploy our extension with `kubectl` in our cluster. 

Create a GitHub account if you don't have one yet, create a new repository and [create a Personal Access Token (PAT)](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token) in GitHub with the [appropriate permissions](https://docs.github.com/en/free-pro-team@latest/packages/getting-started-with-github-container-registry/migrating-to-github-container-registry-for-docker-images#authenticating-with-the-container-registry) and add a secret in the repository, called `CR_PAT` with the PAT key. For sake of semplicity, we will assume that our repository is called `eirini-secscanner`.

Clone the repository, and create a `.github` folder, inside create a new `workflows` folder with a yaml file `docker.yaml` with the following content:

*.github/workflows/docker.yaml*: 
```yaml
name: Publish Docker image
on:
  push:
jobs:
  push_to_registry:
    name: Push Docker image to GitHub Packages
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v2
      -
        name: Set up QEMU
        uses: docker/setup-qemu-action@v1
      -
        name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1
      -
        name: Login to GitHub Container Registry
        uses: docker/login-action@v1
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.CR_PAT }}
      -
        name: Build and push
        id: docker_build
        uses: docker/build-push-action@v2
        with:
          push: true
          tags: ghcr.io/[USER]/eirini-secscanner:latest # NOTE: Replace [USER] with your username here
      -
        name: Image digest
        run: echo ${{ steps.docker_build.outputs.digest }}
```

The GitHub Action will build and push a fresh docker image to the GitHub container registry, that we can later on use it in our cluster to run our extension. 
The Image should be accessible to a url similar to this: `ghcr.io/user/eirini-secscanner:latest`

## 3)  Extension logic

Before jumping in creating our `main.go`, let's focus on our extension logic. EiriniX has support for different kind of extensions, which allows to interact with Eirini applications, or staging pods in different ways:

- MutatingWebhooks -  by having an active component which patches Eirini apps before starting them
- Watcher - a component that just watch and gets notified if new Eirini apps are pushed
- Reconcilers - a component that constantly reconciles a desired state for an Eirini app

An Eirini App workload is represented by a ```StatefulSet```, which then it becomes a pod running in the Eirini namespace. 

Before the app is started, Eirini runs a staging job which builds the image used to start the app.

For our Security scanner (secscanner) makes sense to use a *MutatingWebhook*, we will try to patch the Eirini runtime pod and inject an InitContainer with [trivy](https://github.com/aquasecurity/trivy#embed-in-dockerfile) preventing to starting it in case has security vulnerability.

Since we want [trivy](https://github.com/aquasecurity/trivy#embed-in-dockerfile) to run as a first action, and check if the filesystem of our app is secure enough, we will have to run the InitContainer with the same image which is used for the Eirini app.

So our extension will also have to retrieve the image of the Eirini app - and use that one to run the security scanner.

### Anatomy of an Extension

[EiriniX Extensions](https://github.com/cloudfoundry-incubator/eirinix#write-your-extension) which are *MutatingWebhooks* are expected to provide a *Handle* method which receives a request from the Kubernetes API. The request contains
the pod definition that we want to mutate, so our extension will start by defining a struct:


```golang
package main

type Extension struct{}
```

Our extension needs a `Handle` method, so we can write:

```golang
func (ext *Extension) Handle(ctx context.Context, eiriniManager eirinix.Manager, pod *corev1.Pod, req admission.Request) admission.Response {

	if pod == nil {
		return admission.Errored(http.StatusBadRequest, errors.New("No pod could be decoded from the request"))
  }

	return eiriniManager.PatchFromPod(req, pod)
}

```

Note we need to add a bunch of imports, as our new `Handle` method receives structures from other packages:

-  ```ctx``` is the request context, that can be used for background operations. 
- ```eiriniManager``` is EiriniX, it's an instance of the current execution. 
- ```pod``` is the Pod that needs to be patched - in our case will be our Eirini Extension
- ```req``` is the raw admission request, might be useful for furhter inspection, but we won't use it in our case
- ```eiriniManager.PatchFromPod(req, pod)``` is computing the diff between the raw request and the pod. It's used to return the actual difference we are introducing in the pod

As it stands our extension is not much useful, let's make it add a new init container:


```golang

func (ext *Extension) Handle(ctx context.Context, eiriniManager eirinix.Manager, pod *corev1.Pod, req admission.Request) admission.Response {

	if pod == nil {
		return admission.Errored(http.StatusBadRequest, errors.New("No pod could be decoded from the request"))
	}
	podCopy := pod.DeepCopy()

	secscanner := v1.Container{
		Name:            "secscanner",
		Image:           "busybox",
		Args:            []string{"echo 'fancy'"},
		Command:         []string{"/bin/sh", "-c"},
		ImagePullPolicy: v1.PullAlways,
		Env:             []v1.EnvVar{},
	}

	podCopy.Spec.InitContainers = append(podCopy.Spec.InitContainers, secscanner)

	return eiriniManager.PatchFromPod(req, podCopy)
}
```

We have added a bunch of things, let's go over it one by one:

- ```podCopy := pod.DeepCopy()``` creates a copy of the pod, to operate over a copy instead of a real pointer
- ```secscanner....``` it's our `InitContainer` definition. It contains the `Name`, `Image`, and `Args` fields along with `Commands`. As for now it doesn't do anything useful, but it's a start point so we can experience with our extension.
- ```podCopy.Spec.InitContainers = append(podCopy.Spec.InitContainers, secscanner)``` is appending the InitContainer to the list of the containers in ```podCopy```
- ```return eiriniManager.PatchFromPod(req, podCopy)``` returns the diff patch from the request to the podCopy


## 4) write the main.go

Let's now write a short `main.go` which just executes our extension:

```golang

package main

import (
	"fmt"
	"log"
	"os"
	"strconv"

	eirinix "code.cloudfoundry.org/eirinix"
	"go.uber.org/zap"
)

const operatorFingerprint = "eirini-secscanner"

var appVersion string = ""

func main() {

	eiriniNsEnvVar := os.Getenv("EIRINI_NAMESPACE")
	if eiriniNsEnvVar == "" {
		zaplog.Fatal("the EIRINI_NAMESPACE environment variable must be set")
	}

	webhookNsEnvVar := os.Getenv("EXTENSION_NAMESPACE")
	if webhookNsEnvVar == "" {
		zaplog.Fatal("the EXTENSION_NAMESPACE environment variable must be set")
	}

	portEnvVar := os.Getenv("PORT")
	if portEnvVar == "" {
		zaplog.Fatal("the PORT environment variable must be set")
	}
	port, err := strconv.Atoi(portEnvVar)
	if err != nil {
		zaplog.Fatalw("could not convert port to integer", "error", err, "port", portEnvVar)
	}

	serviceNameEnvVar := os.Getenv("SERVICE_NAME")
	if serviceNameEnvVar == "" {
		zaplog.Fatal("the SERVICE_NAME environment variable must be set")
	}

	filter := true

	ext := eirinix.NewManager(eirinix.ManagerOptions{
		Namespace:           eiriniNsEnvVar,
		Host:                "0.0.0.0",
		Port:                int32(port),
		FilterEiriniApps:    &filter,
		OperatorFingerprint: operatorFingerprint,
		ServiceName:         serviceNameEnvVar,
		WebhookNamespace:    webhookNsEnvVar,
	})

	ext.AddExtension(&Extension{})

	if err := ext.Start(); err != nil {
		fmt.Println("error starting eirinix manager", "error", err)
	}

}

```

First we collect options from the environment. This will allow us to tweak easily from the kubernetes deployment the various fields:
- We grab `EIRINI_NAMESPACE` from the environment, it's the namespace used by Eirini to push App
- `EXTENSION_NAMESPACE` is the namespace used by our extension
- `PORT` is the listening port where our extension is listening to
- `SERVICE_NAME` is the Kubernetes service name reserved to our extension. We will need a Kubernetes service resource created before starting our extension. It will be used by Kubernetes to contact our extension while mutating Eirini apps.

Mext we construct the EiriniX manager, which will run our extension under the hood, and will create all the necessary boilerplate resources to talk to Kubernetes:
```golang

filter := true

	ext := eirinix.NewManager(eirinix.ManagerOptions{
		Namespace:           eiriniNsEnvVar,
		Host:                "0.0.0.0",
		Port:                int32(port),
		FilterEiriniApps:    &filter,
		OperatorFingerprint: operatorFingerprint,
		ServiceName:         serviceNameEnvVar,
		WebhookNamespace:    webhookNsEnvVar,
	})
```

Here we just map the settings that we collected in environment variables, that we hand over to EiriniX. The ```OperatorFingerprint```  and ```FilterEiriniApps``` are used to set a fingerprint for our runtime and for filtering eirini apps only respectively.

## 5) Commit the code

Time to try things out!

Commmit and push the code done so far to github, a workflow will trigger automatically, which can be inspected in the "Actions" tab of the repository. 
Now, we should have a docker image, and we are ready to start our extension!


### Make the Docker image public

After GH Action has been executed and the docker image of your extension has been pushed, change its permission setting to public in the [package settings page](https://docs.github.com/en/free-pro-team@latest/packages/managing-container-images-with-github-container-registry/configuring-access-control-and-visibility-for-container-images#configuring-visibility-of-container-images-for-your-personal-account)

## 6) Kube apply, first cluster tests

We need at this point to start our extension, so we will create a file which represent our deployment for kubernetes:

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: eirini-secscanner
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: eirini-secscanner
  namespace: eirini-secscanner
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: eirini-secscanner-webhook
rules:
- apiGroups:
  - admissionregistration.k8s.io
  resources:
  - validatingwebhookconfigurations
  - mutatingwebhookconfigurations
  verbs:
  - create  
  - delete
  - update
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: eirini-secscanner-secrets
rules:
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - get
  - create
  - delete
  - list
  - update
  - watch
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: eirini-secscanner
rules:
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
  - list
  - update
  - watch

- apiGroups:
  - ""
  resources:
  - events
  verbs:
  - create
  - patch
  - update

- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - delete
  - get
  - list
  - update
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: watch-eirini-1
  namespace: eirini
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: eirini-secscanner
subjects:
- kind: ServiceAccount
  name: eirini-secscanner
  namespace: eirini-secscanner
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: secrets
  namespace: eirini-secscanner
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: eirini-secscanner-secrets
subjects:
- kind: ServiceAccount
  name: eirini-secscanner
  namespace: eirini-secscanner
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: webhook
  namespace: eirini-secscanner
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: eirini-secscanner-webhook
subjects:
- kind: ServiceAccount
  name: eirini-secscanner
  namespace: eirini-secscanner
---
apiVersion: v1
kind: Service
metadata:
  name: eirini-secscanner
  namespace: eirini-secscanner
spec:
  type: ClusterIP
  selector:
    name: eirini-secscanner
  ports:
  - protocol: TCP
    name: https
    port: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: eirini-secscanner
  namespace: eirini-secscanner
spec:
  replicas: 1
  selector:
    matchLabels:
      name: eirini-secscanner
  template:
    metadata:
      labels:
        name: eirini-secscanner
    spec:
      serviceAccountName: eirini-secscanner
      containers:
        - name: eirini-secscanner
          imagePullPolicy: Always
          image: "ghcr.io/mudler/eirini-secscanner:latest"
          env:
            - name: EIRINI_NAMESPACE
              value: "eirini"
            - name: EXTENSION_NAMESPACE
              value: "eirini-secscanner"
            - name: PORT
              value: "8080"
            - name: SERVICE_NAME
              value: "eirini-secscanner"
            - name: SEVERITY
              value: "CRITICAL"
```

Mind to replace `"ghcr.io/[USER]/eirini-secscanner:latest"` with your image, and then apply the yaml with `kubectl`. Our component will be now on the `eirini-secscanner` namespace, intercepting Eirini Apps.

## 7) Extension logic, part two.

We have tried our extension, but doesn't do anything useful - yet. So let's implement what we was aheading for - a secscanner.

This time,  we will inject a container, but the container will have the image of the running App, so we will try to scan the pod that we have intercepted, and we will try to find the container that Eirini created to start our application.


```golang

func (ext *Extension) Handle(ctx context.Context, eiriniManager eirinix.Manager, pod *corev1.Pod, req admission.Request) admission.Response {

	if pod == nil {
		return admission.Errored(http.StatusBadRequest, errors.New("No pod could be decoded from the request"))
	}
	podCopy := pod.DeepCopy()

	var image string
	for i := range podCopy.Spec.Containers {
		c := &podCopy.Spec.Containers[i]
		switch c.Name {
		case "opi":
			image = c.Image
		}
  }
  ....
```

Now we are looping `podCopy` Containers, and we are finding for a container which is named after `opi` - that's by convention the container named by Eirini running your app. We will grab the image string and we store it to `image`.

Knowing the correct image, now we can Inject our container:

```golang


	secscanner := v1.Container{
		Name:            "secscanner",
		Image:           image,
		Args:            []string{`mkdir bin && curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b bin && bin/trivy filesystem --exit-code 1 --no-progress /`},
		Command:         []string{"/bin/sh", "-c"},
		ImagePullPolicy: v1.PullAlways,
		Env:             []v1.EnvVar{},
	}
```

As we would like also to be able to run our extension with replicas, in full HA mode, we will adapt our code to be idempotent, so it doesn't try to inject an init container each time. Before injecting the container, we can add:

```golang


	// Stop if a secscanner was already injected
	for i := range podCopy.Spec.InitContainers {
		c := &podCopy.Spec.InitContainers[i]
		if c.Name == "secscanner" {
			return eiriniManager.PatchFromPod(req, podCopy)
		}
	}


```
To return an empty patch , so we don't patch the pod twice (or more).

Now our extension should look something like: 

```golang

func trivyInject(severity string) string {
	return fmt.Sprintf("curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b tmp && tmp/trivy filesystem --severity '%s' --exit-code 1 --no-progress /", severity)
}
// Extension is the secscanner extension which injects a initcontainer which checks for vulnerability in the container image
type Extension struct{}

func (ext *Extension) Handle(ctx context.Context, eiriniManager eirinix.Manager, pod *corev1.Pod, req admission.Request) admission.Response {

	if pod == nil {
		return admission.Errored(http.StatusBadRequest, errors.New("No pod could be decoded from the request"))
	}
	podCopy := pod.DeepCopy()

	// Stop if a secscanner was already injected
	for i := range podCopy.Spec.InitContainers {
		c := &podCopy.Spec.InitContainers[i]
		if c.Name == "secscanner" {
			return eiriniManager.PatchFromPod(req, podCopy)
		}
	}

	var image string
	for i := range podCopy.Spec.Containers {
		c := &podCopy.Spec.Containers[i]
		switch c.Name {
		case "opi":
			image = c.Image
		}
	}

	secscanner := v1.Container{
		Name:            "secscanner",
		Image:           image,
		Args:            []string{trivyInject("CRITICAL")},
		Command:         []string{"/bin/sh", "-c"},
		ImagePullPolicy: v1.PullAlways,
		Env:             []v1.EnvVar{},
	}

	podCopy.Spec.InitContainers = append(podCopy.Spec.InitContainers, secscanner)

	return eiriniManager.PatchFromPod(req, podCopy)
}


```

We have just moved the bash commmand construction to its own function `trivyInject` so it can take a severity as an option.

Let's commit the code and push it, to have a new image built by GitHub.

Have a look at the complete source code, `extension.go` in this repository.

Kill and delete the extension pod and push an application to see what happens
Bind the redis database instace to your pushed application.

    cf bind-service python-flask-app redis-example-service

You need to restage/restart your application for the redis configuration to be pushed into your app environment. Lets do rolling update with zero downtime.

    cd cf-python-flask-app
    cf7 push python-flask-app --strategy rolling


When the application is ready, it can be tested by storing a value into the Redis database.

* The first curl `GET` will return `key not present`, since we did not store any value for the key `foo`.

        curl --request GET http://python-flask-app.na$seat.kubecf.net/foo

* The second curl `PUT` will return `success`, since we stored the value `bar` for the key `foo`.

        curl --request PUT http://python-flask-app.na$seat.kubecf.net/foo --data 'data=bar'

* The third curl `GET` will return `bar`, since we stored the value of the key `foo` as `bar` in the previous curl.

        curl --request GET http://python-flask-app.na$seat.kubecf.net/foo


To summarize, you have deployed KubeCF, pushed an application, created a redis database instance using minibroker and connected it to your application.

#### Troubleshooting

If you want to re-bind, unbind the service and retry the above commands.


    cf unbind-service python-flask-app redis-example-service


## Operations Hat

### Scale your Diego Cells

There will come a situation in your company in which you need to push more apps. Easy !!!! Scale up the diego cells.

* Upgrade kubecf platform by setting the instances for diego-cell pod to 2. The value can be changed using `--set` argument of helm. We need to set `sizing.diego_cell.instances` to 2.

        helm upgrade kubecf --namespace kubecf \
        --set "sizing.diego_cell.instances=2" \
        --set "system_domain=na$seat.kubecf.net" \
        --set "features.ingress.enabled=true" \
        https://github.com/cloudfoundry-incubator/kubecf/releases/download/v2.2.2/kubecf-v2.2.2.tgz 


Note: A list of configurable values can be found at [values](https://github.com/cloudfoundry-incubator/kubecf/blob/master/deploy/helm/kubecf/values.yaml
).

A new pod `diego-cell-1` should be running :-

        watch kubectl get pods -n kubecf

Note: This will take 7 minutes. So, you can take a break.

Press `Ctrl+C` to exit.

Now, check if your app still exists.
* Go to url in the browser. Make sure to replace the `$seat` variable.

        http://python-flask-app.na$seat.kubecf.net/foo

OR

* Curl the url.

        curl http://python-flask-app.na$seat.kubecf.net/foo


## Operations Hat

### Rotate Cloud Controller encryption key

Lets perform another operator task. Suppose you need to rotate your cloud controller database encryption key. CAPI release has an errand job which rotates your database encryption key. QuarksJob is used to run BOSH errand jobs in KubeCF world.

* Check if there is a QuarksJob for rotation

        kubectl -n kubecf get quarksjobs rotate-cc-database-key

* Trigger it now

        kubectl patch qjob rotate-cc-database-key \
        --namespace kubecf \
        --type merge \
        --patch '{"spec":{"trigger":{"strategy":"now"}}}'

* Wait for few seconds and check if the rotation was succesful by checking the logs

```
podName=`kubectl -n kubecf get pod -l quarks.cloudfoundry.org/qjob-name=rotate-cc-database-key -o jsonpath='{.items[0].metadata.name}'`
kubectl -n kubecf logs $podName rotate-cc-database-key-rotate | grep "Done rotating encryption key for class"
```

Congratulations, you have successfully completed `Dev and Ops with KubeCF` hands on lab. Your training for developer peace is completed. :wink:


## Beyond the Lab

* KubeCF Docs : https://kubecf.suse.dev/docs/
* Minibroker Project : https://github.com/SUSE/minibroker
* Quarks Project : https://github.com/cloudfoundry-incubator/quarks-operator
