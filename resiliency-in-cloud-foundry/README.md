## Introduction

## Learning Objectives

## Lab

Get ClooudFoundry environment
```
$ cd resiliency-in-cloud-foundry
$ git pull
$ cd bbl-labs-user[1-12]
$ eval "$(bbl print-env)"
```

Get ClooudFoundry Credentials
```
$ cat cf_creds.txt
```

Target to CloudFoundry API
```
$ cf api api.user[1-12].altoros-labs.xyz --skip-ssl-validation
$ cf login -u admin -p PASSWORD
$ cf target -o "system" -s "labs"
```

Push and scale application
```
$ cd app
$ cf push
$ cf scale jwar -i 5
$ cf a
```

Get list of containers

```
$ sudo apt-get update
$ sudo apt-get install netcat-openbsd
```
```
$ bosh -d cf ssh diego-cell/0
$ sudo -i
# cd /var/vcap/packages/runc/bin/
# ./runc list
```

Kill application instance
```
$ ./get_guid.sh jwar
$ ./delete_app.sh guid 0

$ kill -9 CONTAINER_PID
$ ./runc list
```

Find IP of diego cells
```
bosh vms | grep diego-cell
```
