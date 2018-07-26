# Lab

In the interest of time, we are going to use Spring Profiles to activate configuration and components. We will discuss what is happening at each step. If you would like to review the code in more detail after the session, you can do so here: https://github.com/rscale-training/consumer. Using profiles in this way is for **TRAINING PURPOSES ONLY**.

## Consumer Application

Each of you should have a consumer application in your space. Use `cf a` to find the URL and open it in a browser.

As a refresher, you:

* set active profiles using the `SPRING_PROFILES_ACTIVE` environment variable
* provide multiple active profiles separated by commas
* use `cf set-env` to set environment variables
* need to restart your app with `cf restart` after changing an environment variable

## Centralized Configuration

To active the consumer as a Spring Cloud Config client, set the `config` profile and restart your app.  After it restarts, refresh the app in your browser.

```
$ cf set-env consumer SPRING_PROFILES_ACTIVE config
$ cf restart consumer
```

The consumer app should show you it is now connected to a config server.

Your instructor just made a change to the config -> the message. You can load this change by performing a `POST` to the `/actuator/refresh` endpoint.

```
$ curl -X POST https://<your-consumer>/actuator/refresh
```

If you reload your app in a browser, you should see the message change. This works because we added the `@RefreshScope` annotation in the `ConsumerController` class, denoting properties can be refreshed without a restart.

### How does it work?

Dependencies in `build.gradle`:

* `org.springframework.cloud:spring-cloud-starter-config` -> The core config client
* `org.springframework.boot:spring-boot-starter-actuator` -> Actuator provides management endpoints including `/actuator/refresh`
* `org.springframework.cloud:spring-cloud-starter` -> Spring cloud context provides bootstrap capabilities and the `@RefreshScope` annotation
* `org.springframework.boot:spring-boot-starter-cloud-connectors` -> Parses the Cloud Foundry environment values including the space name and user provided service instance

Bootstrap configuration in `src/main/resources/bootstrap.yml`:

* **Config Server**: The config server credentials are injected via a User Provided Service instance created by your instructors called `config-server`. The `config` profile was activated by you.

  ```
  spring:
    profiles: config
    cloud:
      config:
        uri: ${vcap.services.config-server.credentials.uri}
        username: ${vcap.services.config-server.credentials.username}
        password: ${vcap.services.config-server.credentials.password}
  ```      
* **Application Name:** The application name is used to fetch configuration from the config server. We are using the space name for training purposes when the `cloud` profile is active (automatically set by the buildpack for boot apps).

  ```
  spring:
    profiles: cloud
    application:
      name: ${vcap.application.space_name}
  ```

Your config client will connect to the Config Server during startup and fetch config before creating the application context. Your instructor will show you the config.

## Service Discovery

Next, we will make our consumer a discovery client, allowing it to discover producer instances.

To active the consumer as a Spring Cloud Discovery client, activate the `discovery` profile and restart your app (don't remove the `config` profile).  After it restarts, refresh the app in your browser.

```
$ cf set-env consumer SPRING_PROFILES_ACTIVE config,discovery
$ cf restart consumer
```

The consumer app should show you it is now connected to a Eureka server. The configuration for Eureka is available to all apps via the config server.

### How it works

Dependencies in `build.gradle`:

* `org.springframework.cloud:spring-cloud-starter-netflix-eureka-client` -> The Eureka client

In code:
* `@EnableDiscoveryClient` annotation (usually in the same class as the main, but in `DiscoveryClientConfig.java` for training)

Configuration:

* in the config server repository

## Consuming with Feign

Now, we can enable Feign, a declarative REST client, to consume from the producer. Feign integrates w/ Eureka.

To active Feign, set the `feign` profile and restart the consumer. After it restarts, refresh the app in your browser (if it fails the first time, refresh it again).

```
$ cf set-env consumer SPRING_PROFILES_ACTIVE config,discovery,feign
$ cf restart consumer
```

### How it works

Dependencies in `build.gradle`:

* `org.springframework.cloud:spring-cloud-starter-openfeign`

In code:

* `ProducerClient.java`
  * `@FeignClient(name = "producer")`: Declares this interface is a Feign client which consumes from an app with the name `producer` as registered in Eureka.
  * `@RequestMapping(method = RequestMethod.GET, value = "/")`: Denotes invoking that method should make a `GET` request to the producer's `/` endpoint.

* `@EnableFeignClients` in `FeignClientConfig.java`: Tell Spring to scan for components with `@FeignClient`

* `ConsumerController.java`: Uses the ProducerClient as any other interface. It has no knowledge of Feign or the remote client.

## Client Side Load Balancing

Eureka tracks instances for each application. Feign will leverage Ribbon, a client side load balancer, transparently provided Ribbon exists.  You don't need to do anything; it is happening under the covers.

### How it works

Dependencies in `build.gradle`:

* `org.springframework.cloud:spring-cloud-starter-netflix-ribbon`

## Preventing Cascading Failure with Hystrix

To simulate an unavailable or slow producer, the instructors have stopped the producer.  If you refresh your consumer now, you should see a 500 error.  This is a terrible user experience and will lead to cascading failures throughout microservice architectures. Hystrix will help prevent this.

To activate Hystrix, replace the `feign` profile with the `feign-with-hystrix` profile. Restart your consumer and  refresh the app in your browser.

```
$ cf set-env consumer SPRING_PROFILES_ACTIVE config,discovery,feign-with-hystrix
$ cf restart consumer
```

If time allows, the instructors will restart the producer.  You can keep refreshing and observe requests succeeding.

### How it works

Dependences in `build.gradle`:

* `org.springframework.cloud:spring-cloud-starter-netflix-hystrix`

In code:

* `@EnableCircuitBreaker` in `FeignClientWithHystrixConfig.java` enables hystrix

* `@FeignClient(name = "producer", fallback=ProducerClientFallback.class)` in `ProducerClientWithFallback.java`: This is the same as the `ProducerClient` above except we declare a fallback implementation to be used a remote call fails or is too slow.

* `ProducerClientFallback.java`: The fallback implementation which returns a useful response immediately (in our case a model object with blank message).

In config:

* Tell Feign to use Hystrix.
