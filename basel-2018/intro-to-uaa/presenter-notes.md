# Presenter notes

## Lab Description

The lab will show how easy it is to deploy, configure and use the Cloud Foundry UAA with your applications.
The attendees will learn how simple it is to have authorization and authentication in their applications.

Time: 30 mins

## Program Description

A special system [Quaa](https://github.com/starkandwayne/quaa) has been authored by Stark & Wayne to make it easy for lab attendees, and any software developers, to run the UAA on their local machines, inside Cloud Foundry, or via BOSH. The attendees will be able to quick run UAA and then spend the bulk of the 30 min lab exploring and running some sample UAA applications using Docker.

## Environment

Attendees can either:

* Use their Unix/Linux based machines with Java 1.8, git, bash, and docker installed
* Use the remote jumpbox with Java 1.8, git, bash, and docker installed

The following additional projects are to be `git clone`d into their machine/jumpbox:

```plain
git clone https://github.com/starkandwayne/quick-uaa-local ~/workspace/quick-uaa-local
git clone https://github.com/starkandwayne/quick-uaa-deployment-cf ~/workspace/quick-uaa-deployment-cf
git clone https://github.com/starkandwayne/ultimate-guide-to-uaa-examples ~/workspace/ultimate-guide-to-uaa-examples
```

The former is the `quaa` tool to run a local UAA. The latter is a set of example UAA-based applications.

As an extension to the lab:

* Attendees can try deploying UAA to a Cloud Foundry, which requires a MySQL or PostgreSQL servive instance. The attendees can then run thru the example applications with their Cloud Foundry-deployed UAA.

## Setup

Check that Java 1.8, git, and docker are installed:

```plain
java -version
git --version
docker version
```

# Issues
