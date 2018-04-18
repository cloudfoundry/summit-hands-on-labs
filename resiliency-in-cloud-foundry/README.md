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
$ gradlew
$ cf push
$ cf scale spring-music -i 3 
```

Kill application instance
```
$ ./get_guid.sh spring-music
$ ./delete_app.sh guid 1
```
