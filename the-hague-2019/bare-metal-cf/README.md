# Excellent Adventures in Bare Metal CF

## Introduction
In this hands-on-lab you will deploy a CloudFoundry environment on a bare-metal CoreOS cluster. 
In the interest of time, this cluster has been setup beforehand using Terraform and is hosted by [Packet](http://packet.com).

To reproduce this environment by your self, Use the following open sourced project created by [Stark & Wayne](https://www.starkandwayne.com/). 
Which will bootstrap your CoreOS Cluster, and enable a static flannel network and install [BUCC](https://github.com/starkandwayne/bucc) on the first cluster member.

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
Use the repipe scripte to update / create the pipeline configuration for your pipeline.

Since all students are sharing the same Concourse you will need to provide your __User Index__.
```
# training.hol.XX@cloudfoundry.org
./ci/repipe XX
```

you will see a link to your pipeline. when running the above repipe script

### run pipeline
go to the concourse web ui. and press that nice little play button on your pipeline...

### check bosh
` bosh instances -d cf-YOUR_USER_NR` e.g bosh instances -d cf-02
you will notice that the ip address are in

## Chose your own (Excellent) Adventure
