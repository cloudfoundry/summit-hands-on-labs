# Excellent Adventures in Bare Metal CF

## Introduction
In this hands-on-lab you will deploy a Cloud Foundry environment on a bare-metal CoreOS cluster.
In the interest of time, this cluster has been setup beforehand using Terraform and is hosted by [Packet](http://packet.com).

The Terraform project used to create this environment will be open sourced by [Stark & Wayne](https://www.starkandwayne.com/) at a later date.

### Architecture
For this exersise we will be using a 3 node cluster.
During bootstrap a static flannel overlay network has been created.
Each node runs a docker daemon which has been mapped to a availablity zone using [BOSH CPI Config](https://bosh.io/docs/cpi-config/).
```
+-------------------------------------+
|           ||           ||           |
+-------------------------------------+
||      ||                           ||
|| BUCC ||                           ||
||      ||     Cloud Foundry 1-12    ||
+--------+                           ||
|        |                           ||
|        |                           ||
|        +----------------------------+
|           ||           ||           |
|flannel /28||flannel /28||flannel /28|
| CoreOS Z0 || CoreOS Z1 || CoreOS Z2 |
+-------------------------------------+
```

With the above out of the way, lets see if we can break bare-metal.
All students will be sharing the same cluster, so just rember: __Be excellent to each other!__

## Access BUCC
To access bucc, execute the snippet provided by the instructor in the Google Cloud Shell.
```
# Execute snippet shared by presenter
```

Doing so will install the `bucc-shell` command in your session.
Now Run:
```
bucc-shell
```

### Concourse web UI
One of the C's in BUCC stands for [Concourse](https://concourse-ci.org/), which means we can use a continious delivery pipeline to deploy our Cloud Foundry.

Use the `bucc` cli to retrieve the details to login to concourse in an other browser tab:
```
bucc info
```

### Configure fly cli
The Concourse cli is called `fly`, we can use `bucc` to download and set it up:
```
bucc fly
```

Verify we are in business by listing the registered concourse workers:
```
fly -t bucc workers
```

## Deploy your Cloud Foundry
Lets now deploy Cloud Foundry for which we will be using Concourse.
Use the repipe script to update / create the pipeline configuration for your pipeline.

Since all students are sharing the same Concourse, you will need to use the __student number__ from the handout.

```
./repipe YOUR_STUDENT_NUMBER
```

Navigate to your pipeline in the Concourse web UI.

TIP: _A deeplink to the pipeline is shown in the output form the repipe script._

### Kickoff the Deployment Pipeline
In the Concourse UI:
1. navigate to the "__deploy-cf__" job of your pipeline
1. click on the "__+__" button to start the deployment

Concourse will now perform the following tasks:
- Download the latest bosh stemcell from [bosh.io](https://bosh.cloudfoundry.org/stemcells/)
- Get the latest stable [cf-deployment release](https://github.com/cloudfoundry/cf-deployment/releases)
- Upload the stemcell to the BOSH director
- Apply the [specified opsfiles](https://github.com/cloudfoundry/summit-hands-on-labs/blob/master/the-hague-2019/bare-metal-cf/deploy-cf-pipeline.yml#L16-L20) to the [base manifest](https://github.com/cloudfoundry/cf-deployment/blob/master/cf-deployment.yml)
- Perform a BOSH deploy with the resulting manifest

## Choose your own (Excellent) Adventure
At this point there should be a bunch of CF deployments running on our bare metal cluster.
To get a feeling for the performance of bare-metal try some of the experiments below:

#### Deploy and scale an App
- Use credhub to find admin credentials `bucc credhub && credhub find -n admin`
- Exit the bucc shell (since it does not have the cf cli installed and target your CF
- Deploy an app (for example [cf-env](https://github.com/cloudfoundry-community/cf-env)
- Scale it to 100 instances
- Apply some load, use for example [wrk](https://github.com/wg/wrk)
