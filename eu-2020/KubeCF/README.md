
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

* Exit the shell.

        exit

## EiriniX Logging

`cf logs` also doesn't work with Eirini. You need EiriniX Logs extension for the sub command to work. EiriniX Logs comes by default with `KubeCF` installation.

* You view the logs of the pushed application using 

        cf logs python-flask-app --recent

## Write your own EiriniX (Eirini extension)

In this task, we will write an extension for Eirini with EiriniX. The extension is a security-oriented one. For example, we want to prevent from being pushed Eirini apps that doesn't pass a vulnerability scan.

[trivy](https://github.com/aquasecurity/trivy#embed-in-dockerfile) is a perfect fit, and we will try to run it in an `InitContainer` before starting the Cloud Foundry Application, preventing it to run if it fails `trivy` validations.

### Prepare Project folder

* Make a new folder

        mkdir extension
        cd extension
        go mod init github.com/$USER/eirini-secscanner

* Create go.mod packages with necessary 

        go get code.cloudfoundry.org/eirinix@v0.3.1-0.20200908072226-2c03042398ea

### Prepare Code files

Before jumping in to creating our `main.go`, let's focus on our extension logic. EiriniX does support different kind of extensions, which allows to interact with Eirini applications, or staging pods in different ways:

- MutatingWebhooks -  by having an active component which patches Eirini apps before starting them
- Watcher - a component that just watch and gets notified if new Eirini apps are pushed
- Reconcilers - a component that constantly reconciles a desired state for an Eirini app

An Eirini App workload is represented by a ```StatefulSet```, which then it becomes a pod running in the Eirini namespace. 

Before the app is started, Eirini runs a staging job which builds the image used to start the app.

For our Security scanner (secscanner) makes sense to use a *MutatingWebhook*, we will try to patch the Eirini runtime pod and inject an InitContainer with [trivy](https://github.com/aquasecurity/trivy#embed-in-dockerfile) preventing to starting it in case has security vulnerability.

Since we want [trivy](https://github.com/aquasecurity/trivy#embed-in-dockerfile) to run as a first action, and check if the filesystem of our app is secure enough, we will have to run the InitContainer with the same image which is used for the Eirini app.

So our extension will also have to retrieve the image of the Eirini app - and use that one to run the security scanner.

#### Anatomy of an Extension

[EiriniX Extensions](https://github.com/cloudfoundry-incubator/eirinix#write-your-extension) which are *MutatingWebhooks* are expected to provide a *Handle* method which receives a request from the Kubernetes API. The request contains
the pod definition that we want to mutate, so our extension will start by defining a struct. Following command will create the `extension.go` file.

```golang
cat<<EOF >> extension.go
package main

import (
    "context"
    "errors"
    "net/http"

    eirinix "code.cloudfoundry.org/eirinix"
    corev1 "k8s.io/api/core/v1"
    "sigs.k8s.io/controller-runtime/pkg/webhook/admission"
)

type Extension struct{}

EOF
```

Our extension needs a `Handle` method, so we can write and let's make it add a new init container through `Handle` method.

```golang
cat<<EOF >> extension.go
func (ext *Extension) Handle(
    ctx context.Context,
    eiriniManager eirinix.Manager,
    pod *corev1.Pod, 
    req admission.Request) admission.Response {
	
    if pod == nil {
		return admission.Errored(http.StatusBadRequest, errors.New("No pod could be decoded from the request"))
    }
    podCopy := pod.DeepCopy()

    secscanner := corev1.Container{
	    Name:            "secscanner",
	    Image:           "busybox",
	    Args:            []string{"echo 'fancy'"},
	    Command:         []string{"/bin/sh", "-c"},
	    ImagePullPolicy: corev1.PullAlways,
	    Env:             []corev1.EnvVar{},
    }

    podCopy.Spec.InitContainers = append(podCopy.Spec.InitContainers, secscanner)

    return eiriniManager.PatchFromPod(req, podCopy)
}

EOF
```

Note we need to add a bunch of imports, as our new `Handle` method receives structures from other packages:

-  ```ctx``` is the request context, that can be used for background operations. 
- ```eiriniManager``` is EiriniX, it's an instance of the current execution. 
- ```pod``` is the Pod that needs to be patched - in our case will be our Eirini Extension
- ```req``` is the raw admission request, might be useful for furhter inspection, but we won't use it in our case

We have added a bunch of things, let's go over it one by one:

- ```podCopy := pod.DeepCopy()``` creates a copy of the pod, to operate over a copy instead of a real pointer
- ```secscanner....``` it's our `InitContainer` definition. It contains the `Name`, `Image`, and `Args` fields along with `Commands`. As for now it doesn't do anything useful, but it's a start point so we can experience with our extension.
- ```podCopy.Spec.InitContainers = append(podCopy.Spec.InitContainers, secscanner)``` is appending the InitContainer to the list of the containers in ```podCopy```
- ```return eiriniManager.PatchFromPod(req, podCopy)``` returns the diff patch from the request to the podCopy

#### Write our "main.go"

Let's now write a short `main.go` which just executes our extension:

```golang
cat<<EOF >> main.go
package main

import (
	"fmt"
	"log"
	"os"
	"strconv"

	eirinix "code.cloudfoundry.org/eirinix"
)

const operatorFingerprint = "eirini-secscanner"

var appVersion string = ""

func main() {

	eiriniNsEnvVar := os.Getenv("EIRINI_NAMESPACE")
	if eiriniNsEnvVar == "" {
		log.Fatal("the EIRINI_NAMESPACE environment variable must be set")
	}

	webhookNsEnvVar := os.Getenv("EXTENSION_NAMESPACE")
	if webhookNsEnvVar == "" {
		log.Fatal("the EXTENSION_NAMESPACE environment variable must be set")
	}

	portEnvVar := os.Getenv("PORT")
	if portEnvVar == "" {
		log.Fatal("the PORT environment variable must be set")
	}
	port, err := strconv.Atoi(portEnvVar)
	if err != nil {
		log.Fatal("could not convert port to integer", "error", err, "port", portEnvVar)
	}

	serviceNameEnvVar := os.Getenv("SERVICE_NAME")
	if serviceNameEnvVar == "" {
		log.Fatal("the SERVICE_NAME environment variable must be set")
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
EOF
```

First we collect options from the environment. This will allow us to tweak easily from the kubernetes deployment the various fields:
- We grab `EIRINI_NAMESPACE` from the environment, it's the namespace used by Eirini to push App
- `EXTENSION_NAMESPACE` is the namespace used by our extension
- `PORT` is the listening port where our extension is listening to
- `SERVICE_NAME` is the Kubernetes service name reserved to our extension. We will need a Kubernetes service resource created before starting our extension. It will be used by Kubernetes to contact our extension while mutating Eirini apps.

Next we construct the EiriniX manager, which will run our extension under the hood, and will create all the necessary boilerplate resources to talk to Kubernetes:

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


### Dockerfile

* At this point we can write up a Dockerfile to build our extension, it just needs to build a go binary and offer it as an entrypoint. Create a file `Dockerfile` with the following content:

```Dockerfile
cat<<EOF >> Dockerfile
ARG BASE_IMAGE=opensuse/leap

FROM golang:1.14 as build
ADD . /eirini-secscanner
WORKDIR /eirini-secscanner
RUN CGO_ENABLED=0 go build -o eirini-secscanner
RUN chmod +x eirini-secscanner

FROM opensuse/leap
COPY --from=build /eirini-secscanner/eirini-secscanner /bin/
ENTRYPOINT ["/bin/eirini-secscanner"]
EOF
```

* Build the docker image.

        docker build . -t gcr.io/summit-labs/eirini-secscanner-$USER

* Push the docker image.

        docker push gcr.io/summit-labs/eirini-secscanner-$USER

## Let's test it!

We need at this point to start our extension.

In the Kubernetes deployment file, we are creating a `serviceAccount` that has permission to register `mutatingwebhooks` at cluster level and that can operate on secrets on the namespace where it belongs. We also give permissions over the target namespace (the Eirini one, and we assume it's `eirini`) to operate on `pods`, `events` and `namespace` resource.

Finally we create a service which will be consumed by the extension.

At the end should look more or less like the following:

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

* Apply the yaml file using the following command

        kubectl apply -f https://raw.githubusercontent.com/mudler/eirini-secscanner/main/contrib/kube.yaml

Apply the yaml, and watch the `eirini-secscanner` namespace, a pod should appear and go to running, our extension is up!

Let's try to push a sample app with CF, and then inspect the app pod in the `eirini` namespace, it should have an `InitContainer` named `secscanner` injected (which just echoes) that ran successfully.

## Extension logic, part two

We have tried our extension, but doesn't do anything useful - yet - it just echoes a text in an `InitContainer`. So let's go ahead and run `trivy` instead of echoing text.

This time,  we will inject a container, but the container needs to run on the same image of the Eirini App, so we will try to scan the pod that we have intercepted, and we will try to find the container that Eirini created to start our application.


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

Now we are looping `podCopy` Containers, and we are looking for a container which is named after `opi` - that's by convention the container created by Eirini. We will grab the image string and we store it into the `image` variable.

We know now the correct image, so we are ready to tweak our container:

```golang


	secscanner := corev1.Container{
		Name:            "secscanner",
		Image:           image,
		Args:            []string{`mkdir bin && curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b bin && bin/trivy filesystem --exit-code 1 --no-progress /`},
		Command:         []string{"/bin/sh", "-c"},
		ImagePullPolicy: corev1.PullAlways,
		Env:             []corev1.EnvVar{},
	}
```

We also have to take care of the resource used. If no `requests/limits` are specified, Kubernetes will apply the same limits of sillibings containers to ours, and this will cause our secscanner to get `OOMKilled` if someone pushes an app with a small memory limit set.

We will then set a specific memory request in our container:

```golang
  	q, err := resource.ParseQuantity("500M")
		if err != nil {
			return admission.Errored(http.StatusBadRequest, errors.New("Failed parsing quantity"))
    }
    ...
		secscanner.Resources = corev1.ResourceRequirements{
			Requests: map[corev1.ResourceName]resource.Quantity{corev1.ResourceMemory: q},
			Limits:   map[corev1.ResourceName]resource.Quantity{corev1.ResourceMemory: q},
		}
```

mind also to add `resource "k8s.io/apimachinery/pkg/api/resource"` to the imports on top of your main.

As we would like also to be able to run our extension with replicas, in full HA mode, we will adapt our code to be idempotent, so it doesn't try to inject an init container each time. Before injecting the container, we can add a `guard` like so:

```golang

	// GUARD: Stop if a secscanner was already injected
	for i := range podCopy.Spec.InitContainers {
		c := &podCopy.Spec.InitContainers[i]
		if c.Name == "secscanner" {
			return eiriniManager.PatchFromPod(req, podCopy)
		}
	}


```
to return an empty patch so we patch the pod only once.

Now our extension should look something like: 

```golang

func trivyInject(severity string) string {
	return fmt.Sprintf("curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b tmp && tmp/trivy filesystem --severity '%s' --exit-code 1 --no-progress /", severity)
}

// Extension is the secscanner extension which injects a initcontainer which checks for vulnerability in the container image
type Extension struct{}


// Handle takes a pod and inject a secscanner container if needed
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
  
  q, err := resource.ParseQuantity("500M")
	if err != nil {
		return admission.Errored(http.StatusBadRequest, errors.New("Failed parsing quantity"))
   }

	secscanner := corev1.Container{
		Name:            "secscanner",
		Image:           image,
		Args:            []string{trivyInject("CRITICAL")},
		Command:         []string{"/bin/sh", "-c"},
		ImagePullPolicy: corev1.PullAlways,
    Env:             []corev1.EnvVar{},
    Resources: corev1.ResourceRequirements{
			Requests: map[corev1.ResourceName]resource.Quantity{corev1.ResourceMemory: q},
			Limits:   map[corev1.ResourceName]resource.Quantity{corev1.ResourceMemory: q},
		},
	}

	podCopy.Spec.InitContainers = append(podCopy.Spec.InitContainers, secscanner)

	return eiriniManager.PatchFromPod(req, podCopy)
}


```

don't forget about adding `fmt` at the imports.

At this point the only difference is that we have moved the bash command construction to its own function `trivyInject` so it can take a severity as an option and parametrize the `trivy` execution accordingly.

Let's build and commit the code:
```bash
$ git add extension.go
$ git commit -m "Inject security scanner"
$ git push # This will trigger github actions
```

Also git push it, to have a new image built by GitHub. Wait for Github Action to complete and delete the extension pod. Now push an application, and watch the eirini namespace with `watch kubectl get pods -n eirini` to see what happens!

We should see first a staging eirini pod, that afterwards gets deleted to make space to the real Eirini app. If we inspect it closely with `kubectl describe pod -n eirini PODNAME`, we will see it had injected a `secscanner` container.

### Security scanner severity

Now we can also play with the extension itself - as we saw already `trivy` takes a `--severity` parameter which sets the severity levels of the issues found, if the sevirity found matches with the one you selected, it will make the container to exit so the pod doesn't start.

Let's tweak then our `secscanner` container:

```golang

	secscanner := corev1.Container{
		Name:            "secscanner",
		Image:           image,
		Args:            []string{trivyInject(os.Getenv("SEVERITY"))},
		Command:         []string{"/bin/sh", "-c"},
		ImagePullPolicy: corev1.PullAlways,
    Env:             []corev1.EnvVar{},
    Resources: corev1.ResourceRequirements{
			Requests: map[corev1.ResourceName]resource.Quantity{corev1.ResourceMemory: q},
			Limits:   map[corev1.ResourceName]resource.Quantity{corev1.ResourceMemory: q},
		},
	}

```

In this way we can specify the severity with env vars, and edit the deployment.yaml accordingly:

```yaml
      containers:
        - name: eirini-secscanner
        ...
          env:
        ...
            - name: SEVERITY
              value: "CRITICAL" # Try to set it to "HIGH,CRITICAL"
```



Congratulations, you have successfully completed hands on lab. Your training for developer peace is completed. :wink:

## Beyond the Lab

* KubeCF Docs : https://kubecf.io
* Eirni Project : https://github.com/cloudfoundry-incubator/eirini
* Quarks Project : https://github.com/cloudfoundry-incubator/quarks-operator
