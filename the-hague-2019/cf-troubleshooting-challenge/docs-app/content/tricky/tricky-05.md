---
title: "Tricky 05"
date: 2019-09-04T09:13:24+03:00
weight: 405
---

## Application:
A golang web application with a single button, which generate log messages.

## Task:
Deploy an app with a manifest.
App should work, but in his case you should fix the app to see generated logs
in cf logs output. Logs look like `this is test log`

NOTE: we expect you to modify aplication code here, so minimal 
coding experience (any language) is expected.

## ACCEPTANCE CRITERIAS:
- "cf apps" shows at least one instance of an app
- "cf logs APP-NAME --recent" shows recent logs for an app. 
  NOTE: generated logs should be also visible
- an app can be accessed using an app's route

## Tags
tag_manifest tag_goland tag_logs


