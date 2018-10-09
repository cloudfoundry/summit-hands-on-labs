# Environment

* Hosted CF
* Access to https://start.spring.io

# Setup

* Running Spring Cloud Config Server w/ config for Eureka
* Running Eureka instance
* Running (shared) producer instance connected to config and Eureka


cf cups config-server -p '{"uri":"https://boston-config.cfapps.io","username":"boston-user","password":"clAmch0wder"}'


cf push --hostname boston-consumer




## TO Do

* script set up/tear down
* publish jar file somewhere for BYOD users

*  Setup in LMS





## Flow

* Intro slides - what are we doing
  * Show what has been deployed in rscale/boston
  * What has been deployed in each user space:
    * UPSi for config Server
    * Consumer app
* Use of profiles

### Config Server

```
$ cf set-env consumer SPRING_PROFILES_ACTIVE config
$ cf restart consumer
```

* walk through bootstrap.yml

show: https://boston-config.cfapps.io/consumer/cloud
show: https://boston-config.cfapps.io/consumer/cloud,config
* explain difference
* encrypted values
* versioned history

* not only can you manage config centrally, you can also update most without downtime

```
$ curl -X POST https://boston-consumer.cfapps.io/actuator/refresh
```

@RefreshScope in ConsumerController

### Eureka


https://boston-config.cfapps.io/consumer/cloud,config,discovery

http://boston-eureka.cfapps.io/ -> show instances


### Feign
