Summit Hands-On Labs
====================

Welcome to the Hands-on Labs for CF Summit EU 2020

Useful info
-----------

- Slack channel: #cfsummit-labs-and-demos
- Summit dates: June 24-25, 2020
- Slot duration: 1 hour
- Sponsors: Google, Stark & Wayne
- Laptops: student provided
- Number of students: TBD

Teams
-----

1. SUSE (Dev and Ops with KubeCF)
2. SUSE (Stratos
3. VMware (CF-for-K8s)
5. Stark & Wayne (TBD)
6. ResilientScale (Try Cloud Foundry

How to create a lab
-------------------

To start working on a lab, create a sub-folder with your lab name in `na-2020` folder. Standard approach is to copy over the student and presenter templates, and fill them out, though we are open to whatever process gets you to a good lab.  Each lab should clearly specify the resources that it needs (ie shared CF instance, pure IAAS resources, one unique CF instance with admin privileges, or even one CF instance per student with admin privileges).  Then each lab should specify the steps that the student will be walked through.

To GCP project housing the labs is located here: https://console.cloud.google.com/home/dashboard?authuser=0&project=summit-labs. To activate the cloud shell, click on the top right >_ icon, and load the shared docker image with the following command: cloudshell env update-default-image --image gcr.io/starkandwayne-registry/gcp-cloudshell:latest. You should then be able to access all shared dependencies.

As a general goal, we want to ensure things are "hands-on", so avoid pure demos where the students just watch in favor of specific tasks that the students will step through with you.  Try and pre-provision everything and assume "burner accounts" like `HOL-user-01` through `HOL-user-10`, so students can walk up and start as quickly as possible.  Consider what public face we will put on these labs close to the time, ie we will move a subset of this repo to a public one that allows folks to repeat or continue your lab after the event.  
