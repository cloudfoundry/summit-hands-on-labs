# Summit hands-on labs

Welcome to the Hands-on Labs for CF Summit Basel '18!

To start working on a lab, create a folder with your lab name.  Standard approach is to copy over the student and presenter templates, and fill them out, though we are open to whatever process gets you to a good lab.  Each lab should clearly specify the resources that it needs (ie shared CF instance, pure IAAS resources, one unique CF instance with admin privilages, or even one CF instance per student with admin privilages).  Then each lab should specify the steps that the student will be walked through.

As a general goal, we want to ensure things are "hands-on", so avoid pure demos where the students just watch in favor of specific tasks that the students will step through with you.  Try and pre-provision everything and assume "burner accounts" like HOL-user-01 through HOL-user-10, so students can walk up and start as quickly as possible.  Consider what public face we will put on these labs close to the time, ie we will move a subset of this repo to a public one that allows folks to repeat or continue your lab after the event.  


========  Here is txt from Boston Summit '18 that I will just leave here for now, as not sure if its still relevant ================

If you're seeing this, then you're already in the Google Cloud Shell.  This file is open in your IDE.  To your left is a file browser with all of the files for all of the hands-on labs.  Below you is a terminal that has the `cf`, `gcloud` and other tools pre-installed.

If this is your first time loading this cloud shell, then you can clear out any changes the previous student might have made by running:

```
$ nuke
```

Hope you enjoy the lab and take some knowledge home with you!


If you log into https://console.cloud.google.com/cloudshell/editor
as `training.hol.N` (where N is 1-12), password `cfsummith0l`, then
you’ll be sitting at an IDE and a terminal with a home directory 
backed by our git repo.  Feel free to change the README (which the IDE 
kindly shows by default), or the `.bashrc`, etc files to suit your needs.
The latest `cf` is installed, and there’s a `./scripts/nuke` script 
which removes all local changes.
accounts.google.com
Google Cloud Platform
Google Cloud Platform lets you build, deploy, and scale applications,
websites, and services on the same infrastructure as Google.
