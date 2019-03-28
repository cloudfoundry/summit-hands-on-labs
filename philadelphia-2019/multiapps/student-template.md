## Introduction

With this tutorial, by deploying the 'fortune teller' application in CF,You can experience both - the classic `cf push` way of doing this and the multiapps `cf deploy` or `cf bg-depoploy`. Utilize mta archives and parallelized deployment with tha later. Even do a zero downtime update of the app with `cf bg-deploy`.   

## Learning Objectives
 - try declarative ways of deploying and connecting apps & services 
 - experience the native cf push in managing simple interlinked applications
 - see additional automation & benefits the multiapps deployment brings
   - automatic linking between 
   - faster, parallel deployment
   - blue green deployment
   - versioned artefacts consistently deployed across spaces/orgs/landscapes

## Prerequisites

NOTE: For the sessions taking place during CFNA Summit in Philadelphia, all required resources are taken care of.

## Lab


-  [About the fortune teller](#aboutft)
-  [1. workspace/account setup](#setup)
-  [2. Do the cf push](#push)
-  [3. Do the mta build & cf deploy](#deploy)
-  [4. Do the blue-green deploy](#bg)
-  [5. Do the undeploy](#undeploy)

<a name="aboutft"></a> ### About the fortune teller

The name says it all - this simple web app will tell you a new 'fortune' each time you refresh. *Slightly modified version of the https://github.com/spring-cloud-services-samples/fortune-teller[original scs fortune-teller]

It's setup consists of three java spring apps and 2 services depicted in the diagram.

image:docs/images/FortuneTeller.png[]

Apps:

* The fortune-teller-ui: serves java script & static html ui; polls and presents random \'fortunes' from the fortune service app.
* The fortune-teller-service: serves a \'fortune' rest api, providing a single random fortune; consumes a backing database service. 
* The fortune-teller-hystrix-dashboard: optional component, provides a dashboard of the ui app's circuit breaker (hystrix)

Services:

* postgresql backing service - database storing the list of fortunes. 
* application logging service - integration with SCP collecting logs from applications and making them available on an https://logs.cf.eu10.hana.ondemand.com/[ELK stack]

<a name="setup"></a> ## 1. workspace/account setup

Open https://console.cloud.google.com/cloudshell/editor[google cloud shell] using the _provided_ user/password template and number as credentials.

This repository is already cloned in the users current (home) folder. To complete the workspace setup run

    bash ${HOME}/summit-hands-on-labs/philadelphia-2019/multiapps/setup-lab.sh

This script downloads the multiapps cf cli plugin, a build tool, logs you in in SAP Cloud Platform and creates a personal space for the lab.

NOTE: Execute the listed commands in the console at the bottom part of the screen. The file/text editor at the top part may be used to explore the examples. 

IMPORTANT: Execute the tutorial commands in the root of the ~/mtalab directory :warning:

<a name="push"></a> ## 2. Do the cf push

Let's push to the cloud, the out-of-the-box cf way

NOTE: If already familiar with 'cf push' via manifest descriptors, 'cf create-service', 'cf set-env' etc. , you may only review the file 'manifest' in the repo root and jump directly to: <<3. Do the mta build & cf deploy>>

TIP: Of the instructions below, creation of the app entities is possible with a single command `cf push -f manifest`. However, service creation, app reconfiguration and restart would still have to be executed manually. Follow the steps below to work on each, one step at a time. 

#### 2.1 Backing services creation.
The `cf marketplace` command lists all available backing services SCP provides in your space. The `services` command lists all created service instances in the space. 
The following create an `application logs` service instance with plan `lite` named `fortune-logs` and a `postgresql` database one with a \'dev' plan and name: `fortune-service-database` .

    cf marketplace #optional
    cf create-service application-logs lite fortune-logs
    cf create-service postgresql v9.6-dev fortune-service-database
    cf services #to list result

*logs traced by apps, bound to an application logs service can be browsed in the platform's application logging service \'kibana' ui

#### 2.2 UI app
Now push the front-end application fortune-teller-ui with the following

    cf push -f ./manifest-ui

*a cf push manifest file describes one or many apps with their properties like environment variables, memory configurations, bound services etc. 

#### 2.3 Try the UI
You can check out how your app looks like at it's platform generated route. 
List the app details to see it's route and open it in a browser. look for `route: <>`

    cf app fortune-teller-ui

The app url is constructed as the https protocol on that routes: https://<route>
 e.g. https://fortune-teller-ui-grumpy-wombat.cfapps.us10.hana.ondemand.com 

#### 2.4 Hystrix dashboard
The app has no back-end to provide content yet; It's circuit breaker(hystrix) should fall back to a default message and no new fortunes will come with refreshing. Let's add a hystrix dashboard app to monitor how it behaves:

    cf push -f ./manifest-hystrix

Let's configure the dashboard with the front end app url via an environment variable:

    cf set-env fortune-teller-hystrix-dashboard UIURL https://<fortune-teller-ui app route>
    cf restart fortune-teller-hystrix-dashboard

*a restart is required in order for the app to read it's newly set environment variable.

TIP: Open the dashboard app in a browser too. You may verify that it works by refreshing the _ui app page_ a few times while the _dashboard page_ is opened.

#### 2.5 Backend
Let's continue building the application with it's back-end app. The previously created db service will automatically bind to the app as described in the manifest

    cf push -f ./manifest-service

Now let's tell the front end app where to reach the back end. You already found the ui app's route. Find the backend app's route and amend :443 (https port). Set it as 'FORTUNE_SERVICE_FQDN' variable to the ui app:
    
TIP: the backend application route can be acquired with `cf app fortune-teller-service` as described in <<2.3 Try the UI>>. 

    cf set-env fortune-teller-ui FORTUNE_SERVICE_FQDN <route>:443
    #e.g. cf set-env fortune-teller-ui FORTUNE_SERVICE_FQDN fortune-teller-service-wacky-potato.cfapps.eu10.hana.ondemand.com:443
    cf restart fortune-teller-ui

#### 2.6 Test it
Go back to the ui app and refresh it a couple times - each time a random fortune should be displayed for your destiny to follow. 

*Congratulations, you brought your application to life :tada: !* 

#### 2.7 Clean up
Now let's delete everything to free the resources. 

    cf delete -f fortune-teller-ui
    cf delete -f fortune-teller-service
    cf delete -f fortune-teller-hystrix-dashboard
    cf delete-service -f fortune-service-database
    cf delete-service -f fortune-logs


<a name="deploy"></a> ## 3. Do the mta build & cf deploy

The **M**ulti **T**arget **A**pplication model provides a powerful abstraction, capable of depicting complicated relationship between different platform entities. You may find detailed information in the https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/d04fc0e2ad894545aebfd7126384307c.html[SCP online documentation].

Have a look how the fortune teller app is described. Look for the `mtad.yaml` file in the root of the repository. 
This descriptor is used when assembling, deploying/updating the application.

#### 3.1 Assemble an MTAR
Let's assemble an *MTA* archive! The mta archive is a (zip)package, containing the application's full or partial deployable content. It is deployed at once with a single command. It's versioned and may easily be transported and consistently applied to multiple environments e.g. dev/test/prod. 

Assemlbe with the already installed 'mta build tool' `mbt`:

    mbt assemble 

You'll find a new directory `mta_archives` created in the project root. Inside is the new `*.mtar` archive. 

NOTE: You can also assemble a complete mta archive on the fly just before deploying with the `cf deploy --all-moduels --all-resources` 

#### 3.2 cf deploy
Now simply deploy it to the cloud with the following command :zap: :

    cf deploy mta_archives/fortune-teller_0.0.1.mtar

*That is it :tada: !* 

NOTE: If you review the cf deploy command output, you'll notice that application creation is happening in parallel, to optimize making deploy-times. Order may be controlled via modelling \'deployed-after' parameters in the mtad.yaml.  

NOTE: No additional reconfiguration is required either, as the dependencies are modelled in the mtad.yaml and the deployer takes care of them during the app creation. 

#### 3.3 Examine your MTA
You may find info of the mta with the following commands
    
    cf mtas
    cf mta fortune-teller

NOTE: You can check how your app is behaving in the same way as in 2.6 

*Congratulations on your first mta deployment :clap: !* 


<a name="bg"></a> ## 4. Do the blue-green deploy

Ok, you did an initial deployment. Want to see how to update your app? This can be done with *no down time* by the mta *blue green deployment* 	:green_book: :blue_book: !

#### 4.1 A new MTA version

NOTE: There is a branch in this repo, with a modified fortune teller app. If you'd like to do your own changes to the app by changing the source and rebuilding ( `mvn clean install` ; `mbt assemble` ) .

    git checkout 'green-version'
    
#### 4.2 Blue-green deployment
Instead of `cf deploy` this time run `cf bg-deploy`

    cf bg-deploy mta_archives/fortune-teller_0.0.1.mtar

You now have two versions of the app running in parallel on different routes(idle and live). You may examine the new version of the application and verify it's working correctly before switching the live version's traffic to it. You should see minor changes in ui's style & a cheesy message appended to the fortunes by the backend app. 

After making sure it works as expected, run the following command. Find the deploy process id printed in the bg-deploy command output or via the `cf mta-ops` command.

    cf bg-deploy -a resume -i <process_id>

*Enjoy your new app version, deployed without down time :clap: !*  

TIP: You can run the blue-green deployment in one go, without manual test & resume. Leverage the \'zero downtime update' with the `--no-confirm` option

<a name="undeploy"></a> ## 5. Do the undeploy

You're almost done! To free up resources after the exercise, please remove everything created with the following:
    
    cf undeploy fortune-teller --delete-services

## 6. FINISH

*Thank you* for running through the cf push -> cf deploy lab! We hope the experience was fun and useful. 


## Learning Objectives Review

You now have broader knowledge about the advantages of the declarative modelling of cf deployments. The advantages the Multiapps model brings and additional platform entities it can manage. The improvements in performance and zero-down-time updates the mta deployment brings. You can now decide in better context for which cases to use cf push and for which cf deploy/bg-deploy. 

## Beyond the Lab

Find out more about the topic:

- https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/d04fc0e2ad894545aebfd7126384307c.html[Sap Cloud Platform documentation]
- https://cloudfoundry-incubator.github.io/multiapps-controller/[project homepage]
- https://github.com/cloudfoundry-incubator?utf8=%E2%9C%93&q=multiapps[project @ github.com]
- https://www.youtube.com/watch?v=d07DZCuUXyk[youtube]