Incorrect buildpack
===================

Error
-----

```
Error staging application: App staging failed in the buildpack compile phase
FAILED
```

When corrected the buildpack name:

```
Waiting for app to start...
Start unsuccessful
```

Hints
-----

1. List all available buildpacks: `cf buildpacks`
1. What kind of application do you push? Do you use correct buildpack?
1. Check the application logs using `cf logs bazel-03`. What command does Cloud Foundry use to start the app?

Solution
--------

1. Specify node.js buildpack in the manifest

    ```
    - buildpack: go_buildpack
    + buildpack: nodejs_buildpack
    ```

1. Remove unused environmental variables (optional)

    ```
    - env:
    -     GOPACKAGENAME: github.com/lexsys27/bazel-sample-app
    ```

1. Set the start command in the manifest

    ```
    + command: node main.js
    ```