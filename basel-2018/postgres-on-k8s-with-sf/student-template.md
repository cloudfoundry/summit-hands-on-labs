# Provision PostgreSQL on Kubernetes cluster using Service Fabrik

## Introduction
In this lab paticipants will experience the ease with which a new backing service provisioner can be integrated with [Service Fabrik](https://github.com/cloudfoundry-incubator/service-fabrik-broker). They will learn how to bring in new provisioner to provision a PostgreSQL instance on [shoot cluster](https://kubernetes.io/blog/2018/05/17/gardener/) managed by [Gardener](https://gardener.cloud/).

## Learning Objectives
In this lab participant with learn
1. Ease with which they can bring there own components into Service Fabrik
2. Experience PosgreSQL provisioning on Kubernetes Cluster

## Prerequisites
1. Basic understanding of CF ecosystem for example creating a service instance, binding a service instance etc.
2. Basic understanding of [Service Broker](https://github.com/openservicebrokerapi/servicebroker).

## Lab
### Setup Lab environment
Lab workspace directory on cloud shell is ```~/lab-workspace```.
```
$ cd ~/lab-workspace/service-fabrik-lab/
```

You can start with running an initial script, which will install required packages (bbl, expect) if required and login to jumpbox. The script will also setup CF and BOSH environment so that you can readily start working on lab. 
```
$ ./student-setup user[1-12]
```

### Check avaialble services
```
$ cf service-access
```

### Steps to bring in a new provisioner

1. List new CRDS in service-fabrik manifest
2. List new services  in service-fabrik manifest
3. Add new manger job in service-fabrik manifest
```
$ vimdiff manifest-k8s.yml manifest-no-k8s.yml
# To exit, type `esc :q!` twice 
```

### Start Kubernetes manager job
```
$ bosh -nd service-fabrik deploy manifest-k8s.yml
```

### Update broker
```
$ cf update-service-broker service-fabrik-broker broker secret https://10.244.4.2:9293/cf
$ cf service-access
```

### Enable newly available service
```
$ cf enable-service-access pg-crunchydata
$ cf marketplace
```

### Create a Postgresql instance and binding key
```
$ cf create-service pg-crunchydata v1.0 pg-test
$ watch cf service pg-test
# Enter `Ctrl + C` to come out of watch
```

### Check PostgreSQL instance resources in K8S Cluster
A deployment and a service will be created as part of create instance call in K8S cluster and can be identified with instance guid in CF.
```
$ kubectl get deployments
$ kubectl get service
```

### Create a binding key
```
$ cf create-service-key pg-test bindingKey
$ cf service-key pg-test bindingKey
```

### Connect to service using obtained service keys
```
$ psql -h $hostname -p 5432 -U $username -d $db
$ userdb=> \dt
$ userdb=> \q
```

### Delete previously created binding key
```
$ cf delete-service-key -f pg-test bindingKey
$ cf service-key pg-test bindingKey
```

### Delete the PostgreSQL service instance
```
$ cf delete-service -f pg-test
$ watch cf service pg-test
# Enter `Ctrl + C` to come out of watch
```

### Check that PostgreSQL instance resources are deleted in K8S Cluster
```
$ kubectl get deployments
$ kubectl get service
```

## Learning Objectives Review
Now that you have deployed [Service Fabrik](https://github.com/cloudfoundry-incubator/service-fabrik-broker) with provisioner to provision a PostgreSQL instance, you should:
* Understand how to integrate a new provisioner with [Service Fabrik](https://github.com/cloudfoundry-incubator/service-fabrik-broker)
* Don't stop, bring in any service you want

## Beyond the Lab
Write a real provisioner and integrate it with [Service Fabrik](https://github.com/cloudfoundry-incubator/service-fabrik-broker)
* Deploy Service Fabrik on Bosh-Lite: https://github.com/cloudfoundry-incubator/service-fabrik-broker/blob/master/README.md
* Try out existing BOSH and Docker provisioners: https://github.com/cloudfoundry-incubator/service-fabrik-broker/blob/master/README.md#launch-the-managers
* Bring your own provisioner: https://github.com/cloudfoundry-incubator/service-fabrik-broker/blob/master/SF2.0.md 
