---
title: "Tricky 04"
date: 2019-09-05T09:13:01+03:00
weight: 404
---

## Application:
A python non web application, which do some calculations and writing logs.

## Task:
Deploy an app with a manifest. This is complex task, we expect some manifest
additions and some files to be created. Several issues in this lab 
repeat the issues from not so tricky labs. 

## ACCEPTANCE CRITERIAS:
- "cf apps" shows at least one instance of an app
- "cf logs APP-NAME --recent" shows recent logs for an app
NOTE: this is not web app, so not need to check app route in browser

## Tags
tag_manifest tag_python

