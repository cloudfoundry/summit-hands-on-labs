## Introduction

## Learning Objectives

## Lab

Get ClooudFoundry environment
```
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

Clone, push and scale application
```
$ git clone https://github.com/cloudfoundry-samples/spring-music.git
$ cd spring-music
$ ./gradlew
$ cf push
$ cf scale spring-music -i 3
$ cf a
```

Get list of containers

```
$ bosh -d cf ssh diego-cell/0
$ sudo -i
# cd /var/vcap/packages/runc/bin/
# ./runc list
```

Kill application instance
```
$ ./get_guid.sh spring-music
$ ./delete_app.sh guid 0

$ kill -9 CONTAINER_PID
$ ./runc list
```

Find IP of diego cells
```
bosh vms | grep diego-cell
```
