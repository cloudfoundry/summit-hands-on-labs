Troubleshooting Challenge
=========================

Description
-----------

In this lab students will play the game. They need to troubleshoot as many Cloud Foundry applications as they can during the timeframe. Applications may have different defects hidden: in configuration, code or infrastructure. Student goal is to find this defects and fix them.

Environment
-----------

Shared Cloud Foundry environment with a space per attendee.

Setup
-----

1. Run app from the exercise 03 in the `system` org

Exercises
---------

1. Large app: app exceeds 1G limit
1. Incorrect buildpack: push node.js app with go buildpack
1. Route conflict: the route already in use
1. Out of memory: container uses more memory then allowed
1. Wrong port: container listens on the wrong port