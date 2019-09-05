# Introduction
In this hands-on-lab you will deploy a CloudFoundry environment on a barem-metal CoreOS cluster.
in the interest of time this cluster has beenn before-hand usign Terraform and is hosted by [Packet](http://packet.com).
To reproduce this environment by your self, Use the following open sourced project created by [Stark & Wayne](https://www.starkandwayne.com/)
here: LINK!!!!
Which will bootstrap your CoreOS Cluster, and enable a static flannel network and install [BUCC](https://github.com/starkandwayne/bucc) on the first cluster member.

# Access BUCC
To access bucc, Please use the snippet from the slide
which will install the `bucc-shell` command.
Run the following command to verify and start your bucc-shell:
```
bucc-shell
```

# login to concourse web ui
```
bucc info
```
by running bucc info you will get the login credentials to login to concourse
with username/password

# configure the fly cli
setup a fly target
```
bucc fly
```

# add pipeline
```
ci/repipe YOUR_USER_NR
```
e.g ci/repipe 2

you will see a link to your pipeline. when running the above repipe script

# check your cloud-config
needed for public ip
by running `bosh configs` you will see a list of precreated cloud-config files
you can view your config file by selecting the cf-YOUR_USER_NR-hol with
```
bosh --type=cloud --name=cf-YOUR_USER_NR-hol
```
e.g bosh config --type=cloud --name=cf-02-hol

TODO: talk about port bindings!!!!!!!!


# run pipeline
go to the concourse web ui. and press that nice little play button on your pipeline...

# check bosh
` bosh instances -d cf-YOUR_USER_NR` e.g bosh instances -d cf-02
you will notice that the ip address are in

# look at the nice big screen to see your containers spawning yeeeeeh wat leukkkk
