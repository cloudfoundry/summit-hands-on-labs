Large app
=========

Error
-----

```
Job (45a18d08-9e4d-408b-a4f5-eb755db3fe40) failed: The app package is invalid: Package may not be larger than 1073741824 bytes
FAILED
```

Hints
-----

1. How much space does current directory consume? What consumes this space?

    ```
    $ ls -lah
    total 1.1G
    drwxr-xr-x 5 lexsys staff  160 Sep 12 13:03 .
    drwxr-xr-x 4 lexsys staff  128 Sep 12 13:00 ..
    -rw-r--r-- 1 lexsys staff 1.0G Sep 12 13:03 .backup
    -rw-r--r-- 1 lexsys staff  340 Sep 12 13:00 main.go
    -rw-r--r-- 1 lexsys staff  140 Sep 12 13:08 manifest.yaml
    ```

1. Exclude `.backup` file from the upload

Solution
--------

1. Create `.cfignore` file in the app directory
1. Add `.backup` file to `.cfignore`

    ```
    echo .backup > .cfignore
    ```
    