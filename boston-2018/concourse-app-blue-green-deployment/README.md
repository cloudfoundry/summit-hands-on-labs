# cfna2018-blue
A Test App for Blue-Green Deployment Hands-on Labs

## How to Run this lab
A jumphost has been provisioned with 12 users. Each corresponds to one of the lab computers. You can log in to this jumphost by using the number of your workstation ${n}. The password is provided by your instructor. 

`ssh cfdev${n}@bg-lab2.cfna2018.starkandwayne.com`

There is a clone of this repository waiting for you in your users home directory. 

`cd cfna2018-blue`

The github username for the lab computer user has already been added to cfna2018/ci/settings.yml but if you are not using a lab computer you must add your github user to this file. 

Now we need to log in to the concourse pipeline, the password is provided by your instructure. 

`fly -t cfna2018 login -k -u ci -p ${CONCOURSE_PASSWORD} -c https://ci.cfna2018.starkandwayne.com`

Once we've successfuly logged in to concourse we can run the repipe command. This command will rund the provided pipeline automation, jobs and tasks, on our lab concourse pipeline.  

`./ci/repipe.sh`

## View your Concourse Pipeline
https://ci.cfna2018.starkandwayne.com

## Get a summary of all the pipelines in the lab
https://ci.cfna2018.starkandwayne.com/beta/dashboard

## Test Development workflow
* Edit the application https://github.com/training-hol-${n}/cfna2018-blue/blob/master/index.js
* The simplest noticeable effect is to uncomment line 35
* This will trigger the pipeline

