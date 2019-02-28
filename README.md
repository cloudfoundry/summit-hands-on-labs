Summit Hands-On Labs
====================

Welcome to the Hands-on Labs for CF Summit Philadelphia '19!

Useful info
-----------

- Slack channel: #handsonlabs-basel-18
- Summit dates: April 3-4, 2019
- Slot duration: 30 minutes
- Number of slots: 12
- Infrastructure provider: Google Cloud, ?
- Laptops: student provided
- Number of students: up to 10

Teams
-----

Each team has two slots. They can do one lab two times, two separate labs or two parts of the same lab.

1. Resilient Scale
1. Stark & Wayne
1. Altoros
1. SAP 1
1. SAP 2
1. Pivotal
1. Dynatrace

Timeline
--------

- August 8:
  - [ ] lab descriptions are ready
- Sep 19:
  - [ ] lab demoed at the call
  - [ ] each lab was done at least one
  - [ ] draft documentation for the lab is ready
  - [ ] draft code was commited to this repo
- Oct 3:
  - [ ] final documentation for the lab is ready
  - [ ] final code was commited to this repo
  - [ ] public version of this repo that allows participants redo the labs is live
  - [ ] instructors have access to the infrastructure provider account to verify everything works fine
- Oct 9:
  - [ ] instructors have access to the chromebooks and have time to set up
- Oct 10-11: labs take place

How to create a lab
-------------------

To start working on a lab, create a sub-folder with your lab name in `basel-2018` folder.  Standard approach is to copy over the student and presenter templates, and fill them out, though we are open to whatever process gets you to a good lab.  Each lab should clearly specify the resources that it needs (ie shared CF instance, pure IAAS resources, one unique CF instance with admin privilages, or even one CF instance per student with admin privilages).  Then each lab should specify the steps that the student will be walked through.

As a general goal, we want to ensure things are "hands-on", so avoid pure demos where the students just watch in favor of specific tasks that the students will step through with you.  Try and pre-provision everything and assume "burner accounts" like `HOL-user-01` through `HOL-user-10`, so students can walk up and start as quickly as possible.  Consider what public face we will put on these labs close to the time, ie we will move a subset of this repo to a public one that allows folks to repeat or continue your lab after the event.  
