
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

In general, apps pushed into Cloud Foundry are ephermal and the data from the apps is not persisted. In any case, you would like to have your data persisted, you need to use the EiriniX Persi extension. In simple words, eirini extensions (EiriniX) are used modify the `Eirini` app pods according to your usecase. In our current case, we want our `Eirini` apps to have access to a persistent storage volume.

* A volume is needed where you can store the output from your application. In Cloud Foundry, service brokers are used to create services which provide storage capacity. So, lets create a service broker.

        BROKER_PASS=$(kubectl get secrets -n kubecf -o json persi-broker-auth-password | jq -r '.data."password"' | base64 -d)

        cf create-service-broker eirini-persi admin $BROKER_PASS http://eirini-persi-broker:8999

* Enable access to all services of the broker.

        cf enable-service-access eirini-persi

* List plans available from the broker. You can see a storage service which can provide you with persistant storage.

        cf marketplace -s eirini-persi

* Create a service named `eririni-persi` which will provide us a volume.

        cf create-service eirini-persi default eirini-persi-volume -c '{"access_mode": "ReadWriteOnce"}'

* Check if the storage is created for us by the service.

        kubectl get pvc -n eirini

* Bind the service to the application so that the storage gets mounted to the app.

        cf bind-service python-flask-app eirini-persi-volume

* Restage the app for a binding to work. 

        cf restage python-flask-app

* You can find the `volume_mounts` details in `VCAP_SERVICES` environment json.

        cf env python-flask-app

* Lets test if the app can access the volume. Let;s, create a file in the volume by hitting `/create` api endpoint which will create a file named `volumeText.txt` for us inside the persistent storage volume.

        curl http://python-flask-app.eu$SEAT.kubecf.net/create

## EiriniX SSH

`cf ssh` doesn't work with Eirini. You need EiriniX SSH extension for the sub command to work. EiriniX SSH comes by default with `KubeCF` installation.

* You can ssh into the pushed application pod using 

        cf ssh python-flask-app

* Now, lets find out if the file that we created in the previous task really exists ? Go to the mounted volume and check for the file created.

        export MOUNT_PATH=$(env | grep container_dir | cut -d":" -f2- | sed "s/,$//" | tr -d '"')
        ls $MOUNT_PATH

* It exists. Now, Exit the shell.

        exit

## EiriniX Logging

`cf logs` also doesn't work with Eirini. You need EiriniX Logs extension for the sub command to work. EiriniX Logs comes by default with `KubeCF` installation.

* You view the logs of the pushed application using 

        cf logs python-flask-app --recent

## Write your own EiriniX (Eirini extension)

In this task, we will write an extension for Eirini with EiriniX. The extension is a security-oriented one. For example, we want to prevent from being pushed Eirini apps that doesn't pass a vulnerability scan.

[trivy](https://github.com/aquasecurity/trivy#embed-in-dockerfile) is a perfect fit, and we will try to run it in an `InitContainer` before starting the `Eirini app`, preventing it to run if it fails `trivy` validations.

### Prepare Project folder

* Make a new folder

        cd ..
        mkdir extension
        cd extension
        go mod init github.com/$USER/eirini-secscanner

* Fetch `eirinix` go package to include it into the project.

        go get code.cloudfoundry.org/eirinix@v0.3.1-0.20200908072226-2c03042398ea

### Prepare Code files

In this task, we will creating two files `main.go` and `extension.go`.

Before jumping into creating our `main.go` for the go package, let's focus on our extension logic. EiriniX does support different kind of extensions, which allows to interact with Eirini applications, or staging pods in different ways:

- MutatingWebhooks -  by having an active component which patches Eirini apps before starting them
- Watcher - a component that just watch and gets notified if new Eirini apps are pushed
- Reconcilers - a component that constantly reconciles a desired state for an Eirini app

An Eirini App is represented by a ```StatefulSet```, which then it becomes a pod running in the Eirini namespace. 

For our Security scanner `trivy` (secscanner), it makes sense to use a *MutatingWebhook*, we will try to patch the Eirini app pod and inject an `InitContainer` which runs [trivy](https://github.com/aquasecurity/trivy#embed-in-dockerfile) preventing to start the `Eirini App pod` in case it has security vulnerabilitys.

We have the following tasks ahead.

* Write extension code which injects `trivy` `InitContainer` into `Eirini app` pods. 
* Convert extension code into a docker image.
* Deploy the docker image in a Kubernetes `deployment`.

#### Anatomy of an Extension

[EiriniX Extensions](https://github.com/cloudfoundry-incubator/eirinix#write-your-extension) which are *MutatingWebhooks* are expected to provide a *Handle* method which receives a request from the Kubernetes API. The request contains
the `Eirini App` pod definition that we want to mutate, so our extension will start by defining a struct. Following command will create the `extension.go` file.

```golang
cat<<EOF >> extension.go
package main

import (
	"context"
	"errors"
	"fmt"
	"net/http"

	eirinix "code.cloudfoundry.org/eirinix"
	corev1 "k8s.io/api/core/v1"
	"sigs.k8s.io/controller-runtime/pkg/webhook/admission"
)

// Extension is the secscanner extension which injects a initcontainer which checks for vulnerability in the container image
type Extension struct{ Memory, Severity string }

EOF
```

Our extension needs a `Handle` method, which will add an `InitContainer` which runs the `triviy` binary inside the `InitContainer`. The `InitContiner` uses the same image on which `Eirini` apps run.

```golang
cat<<EOF >> extension.go

func trivyInject(severity string) string {
	return fmt.Sprintf("curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b tmp && tmp/trivy filesystem --severity '%s' --exit-code 1 --no-progress /", severity)
}

// Handle takes a pod and inject a secscanner container if needed
func (ext *Extension) Handle(
    ctx context.Context,
    eiriniManager eirinix.Manager,
    pod *corev1.Pod,
    req admission.Request) admission.Response {

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

    // Find the container image which needs to be scanned.
    var image string
    for i := range podCopy.Spec.Containers {
    	c := &podCopy.Spec.Containers[i]
    	switch c.Name {
    	case "opi":
    		image = c.Image
    	}
    }

    secscanner := corev1.Container{
    	Name:            "secscanner",
	    Image:           image,
	    Args:            []string{trivyInject(ext.Severity)},
	    Command:         []string{"/bin/sh", "-c"},
	    ImagePullPolicy: corev1.PullAlways,
	    Env:             []corev1.EnvVar{},
    }

	podCopy.Spec.InitContainers = append(podCopy.Spec.InitContainers, secscanner)

	return eiriniManager.PatchFromPod(req, podCopy)
}

EOF
```

Note we have a bunch of arguments to our `Handle` method that receives structures from other packages:

-  ```ctx``` is the request context, that can be used for background operations. 
- ```eiriniManager``` is EiriniX, it's an instance of the current execution. 
- ```pod``` is the Pod that needs to be patched - in our case will be our Eirini App pod.
- ```req``` is the raw admission request, might be useful for further inspection, but we won't use it in our case

We have added a bunch of code, let's go over it one by one:

```
podCopy := pod.DeepCopy()
``` 
creates a copy of the pod, to operate over a copy instead of a real pointer.

```
var image string
for i := range podCopy.Spec.InitContainers {
	c := &podCopy.Spec.InitContainers[i]
	switch c.Name {
	case "opi":
		image = c.Image
	}
}
```

Since we want [trivy](https://github.com/aquasecurity/trivy#embed-in-dockerfile) to run as a first action as `InitContainer`, and check if the filesystem of our app is secure enough, we will have to run the `InitContainer` with the same image that `Eirini App` runs on. So, we store it in a `image` variable.

We know now the correct image, so we are ready to tweak our container:

```
secscanner := corev1.Container{
    Name:            "secscanner",
    Image:           image,
    Args:            []string{trivyInject(ext.Severity)},
    Command:         []string{"/bin/sh", "-c"},
    ImagePullPolicy: corev1.PullAlways,
    Env:             []corev1.EnvVar{},
}

podCopy.Spec.InitContainers = append(podCopy.Spec.InitContainers, secscanner)
```

As we would like also to be able to run our extension with replicas, in full HA mode, we will adapt our code to be idempotent, so it doesn't try to inject an init container each time. Before injecting the InitContainer, we can add a guard like so:

```
// Stop if a secscanner was already injected
for i := range podCopy.Spec.InitContainers {
	c := &podCopy.Spec.InitContainers[i]
	if c.Name == "secscanner" {
		return eiriniManager.PatchFromPod(req, podCopy)
	}
}
```

to return an empty patch so we patch the pod only once.

```
return eiriniManager.PatchFromPod(req, podCopy)
``` 
returns the diff patch from the request to the podCopy.

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
	"go.uber.org/zap"
)

const operatorFingerprint = "eirini-secscanner"

var appVersion string = ""

func main() {
    z, err := zap.NewProduction()
    if err != nil {
    	log.Fatal(fmt.Errorf("could not create logger: %w", err))
    }
    defer z.Sync()
    zaplog := z.Sugar()

    zaplog.Infow("Starting eirini-secscanner", "version", appVersion)
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
    severity := os.Getenv("SEVERITY")
    if severity == "" {
    	severity = "CRITICAL"
    }

    filter := true

    ext := eirinix.NewManager(eirinix.ManagerOptions{
    	Namespace:           eiriniNsEnvVar,
    	Host:                "0.0.0.0",
    	Port:                int32(port),
    	Logger:              zaplog,
    	FilterEiriniApps:    &filter,
        OperatorFingerprint: operatorFingerprint,
    	ServiceName:         serviceNameEnvVar,
    	WebhookNamespace:    webhookNsEnvVar,
    })

    ext.AddExtension(&Extension{Memory: os.Getenv("MEMORY"), Severity: severity})

    if err := ext.Start(); err != nil {
    	zaplog.Fatalw("error starting eirinix manager", "error", err)
    }

    zaplog.Info("eirini-secscanner started")
}
EOF
```

First we collect options from the environment. This will allow us to tweak easily from the kubernetes deployment the various fields:
- We grab `EIRINI_NAMESPACE` from the environment, it's the namespace used by Eirini to push App
- `EXTENSION_NAMESPACE` is the namespace used by our extension
- `PORT` is the listening port where our extension is listening to
- `SERVICE_NAME` is the Kubernetes service name reserved to our extension. We will need a Kubernetes service resource created before starting our extension. It will be used by Kubernetes to contact our extension while mutating Eirini apps.
- Next we construct the EiriniX manager, which will run our extension under the hood, and will create all the necessary boilerplate resources to talk to Kubernetes.

```golang
ext := eirinix.NewManager(eirinix.ManagerOptions{
    	Namespace:           eiriniNsEnvVar,
    	Host:                "0.0.0.0",
    	Port:                int32(port),
    	Logger:              zaplog,
    	FilterEiriniApps:    &filter,
        OperatorFingerprint: operatorFingerprint,
    	ServiceName:         serviceNameEnvVar,
    	WebhookNamespace:    webhookNsEnvVar,
})

ext.AddExtension(&Extension{Memory: os.Getenv("MEMORY"), Severity: severity})
```

* So, we are done creating our two files, `extension.go` and `main.go`. Now, let's convert it into a docker image.

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

We need to deploy the docker image now.

In the Kubernetes deployment file, we are creating a `serviceAccount` that has permission to register `mutatingwebhooks` at cluster level and that can operate on secrets on the namespace where it belongs. We also give permissions over the target namespace (the Eirini one, and we assume it's `eirini`) to operate on `pods`, `events` and `namespace` resource.

Finally we create a service which will be consumed by the extension.

At the end it should look more or less like in this [link](https://raw.githubusercontent.com/rohitsakala/eirini-secscanner/main/contrib/kube.yaml).

* Apply the yaml file using the following command.

        kubectl apply -f https://raw.githubusercontent.com/mudler/eirini-secscanner/main/contrib/kube.yaml

* Let's find out if our externsion pod is running.

        kubectl get pod -n eirini-secscanner

* Since we already have a Eirini app running. Let's restart it so that our extension inserts an init-container `secscanner` `trivy`.

        cf restart python-flask-app

* Now, lets findout if our `secscanner` has passed successfully.

        kubectl logs -l cloudfoundry.org/source_type=APP -n eirini -c secscanner

## Lets Increase the severity

Now we can also play with the extension itself - as we saw already `trivy` takes a `--severity` parameter which sets the severity levels of the issues found, if the sevirity found matches with the one you selected, it will make the container to exit so the pod doesn't start.

* Let's tweak our extension deployment yaml. Change the severity to HIGH.

```
containers:
- name: eirini-secscanner
  ...
  env:
    ...
    - name: SEVERITY
      value: "CRITICAL" # Change it to "HIGH"
```

* Run the following command to tweak the extension deployment.

        kubectl apply -f https://raw.githubusercontent.com/rohitsakala/eirini-secscanner/main/contrib/kube_high.yaml

* Lets restart the app again so the `InitContianer` secscanner is udpated.

        export CF_STARTUP_TIMEOUT=1
        cf restart python-flask-app

* Now, lets findout if our `secscanner` has passed successfully.

        kubectl logs -l cloudfoundry.org/source_type=APP -n eirini -c secscanner

As you can see, this time it finds out some issues and list them in a table. This means our source code is not *extremely* safe.

Congratulations, you have successfully completed hands on lab. Your training for developer peace is completed. :wink:

## Beyond the Lab

* KubeCF Docs : https://kubecf.io
* Eirni Project : https://github.com/cloudfoundry-incubator/eirini
* Quarks Project : https://github.com/cloudfoundry-incubator/quarks-operator
