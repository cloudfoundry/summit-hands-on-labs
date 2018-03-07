## Introduction

In this lab, students will write and deploy a very simple Service Broker and then register this Service Broker in Cloud Foundry and Kubernetes. 
They will exercise the service instance lifecycle and bind a service instance to a sample app in both platforms. 

## Learning Objectives
At the end of this lab, students will:

* Know what the Open Service Broker API (OSPABI) is and why it's beneficial.
* Feel comfortably registering a service broker in both Cloud Foundry and Kubernetes
* Understand how to create service instances, see service plans, and other basic operations in both platforms.

## Prerequisites

* Basic familiarity with the terminal/command line

## Lab

TODO
Basic flow:
1. Create the service broker
2. Deploy the service broker to your CF space
3. CF walkthrough
-- Register broker
-- List plans ?
-- Create a service instance
-- Create a simple app
-- Bind to simple app
4. K8s walkthrough
-- Register broker
-- List plans ?
-- Create a service instance
-- Create a simple app
-- Bind to simple app
Simple app (in progress):
```
var http = require('http');
var util = require('util');

var handleRequest = function(request, response) {
  console.log('Received request for URL: ' + request.url);
  response.writeHead(200);
  response.end('Hello World!' + "\nENV:\n" + util.inspect(process.env));
};
var www = http.createServer(handleRequest);
www.listen(8080);
```
Dockerfile:
```
FROM node:6.9.2
EXPOSE 8080
COPY server.js .
CMD node server.js
```

## Learning Objectives Review

TODO

## Beyond the Lab

Write a real service broker:
* (Link to OSBAPI spec)
* (Link to On-Demand broker)
* (Link to SUSE universal service broker)

Go further with CF:
* (bosh-lite)
* (Something here)

Go further with K8s:
* (Minicube)
* (Something here)
