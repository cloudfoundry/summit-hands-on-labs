---
title: "Tricky 03"
date: 2019-09-05T09:13:02+03:00
weight: 403
---

## Application:
A golang non web application, which just writing logs.

## Task:
Deploy an app with a manifest.
NOTE: we expect manifest based solution here.

## ACCEPTANCE CRITERIAS:
- "cf apps" shows at least one instance of an app
- "cf logs APP-NAME --recent" shows recent logs for an app
NOTE: this is not web app, so not need to check app route in browser

## Tags
tag_manifest tag_golang
