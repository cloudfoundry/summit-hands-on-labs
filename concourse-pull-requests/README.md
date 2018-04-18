# cfna2018-app - A Test Application for Cloud Foundry Summit Labs

This repository contains the code for an example Go application
that will be used in the Cloud Foundry North America Summit 2018,
held in Boston.  Included in this repository is a Concourse
pipeline that handles running tests against all commits made to
the `master` branch.

The lab then discusses the theory of running tests on commits made
against arbitrary Github Pull Requests; in the hands-on segment of
the lab, you get to build out that functionality for real.

To get started, you'll need to fork this repo into your own Github
org, and generate a personal access token for Concourse to use.

For the lab, we have provided a jumpbox with all the necessary
tools on it, and a Concourse installation.  For self-study, all
you need is an instance of the jumpbox BOSH release, deployed
somewhere near your Concourse.
