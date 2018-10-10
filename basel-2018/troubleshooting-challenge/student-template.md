Troubleshooting Challenge
=========================

### Introduction

In this lab you need to find and fix as many defects in the configuration, code or infrastructure as you can in the given timeframe. Make all the apps green!

### Learning Objectives

The lab teaches common techniques and tools for troubleshooting Cloud Foundry applications.

### Prerequisites

You have pre-configured Chromebook with Cloud Foundry CLI installed.

To enjoy the lab you need previous experience in running and configuring apps on Cloud Foundry.

Lab
---

You have only 30 minutes before the demo and 5 apps failing to start. Hurry up! Repair as many apps as you can.

### Setting up the enviornment

Configure the environment. Don't look inside the script!

```
source config.sh
```

It may take about 1 minute for the script to complete.

Target the training organisation.

```
cf target -o training.hol.N
```

where N is your account number. Get it from the start of the command prompt.

```
training_hol_7@cloudshell:

N=7
```

### Push the first app

First of all verify that you can push the reference app:

```
cd 00
cf push
cf apps
```

If it is not up and running call instructor - something happened.

### Hints and Solution

If you are stuck you may get hint with `hint`. Some challenges have additional hints: use `one-more-hint` to show it!

Review the solution with `solution` command. But don't run it too early!

Try them now with the application 00.

### Useful docs

Feel free to use the documentation when needed. Good place to start:

[Troubleshooting application deployment and health](https://docs.cloudfoundry.org/devguide/deploy-apps/troubleshoot-app-health.html)

Troubleshooting
---------------

Now go through the challenges one by one. `cd` each of five directories `01` - `05` and try to push with `cf push`. It fails. Your task is to figure out why and fix the issue.

The challenge is done when the app from this challenge is up and running (as reported by `cf apps`).

Good luck!

Learning Objectives Review
--------------------------

5 minutes before time is over instructor will quickly review all the challenges.
