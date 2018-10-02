Prepare
=======

1. Create 1Gb `.backup` file in the 01 app directory

    ```
    $ cd challenges/01 
    $ dd if=/dev/zero of=.backup bs=1048576 count=1024
    1024+0 records in
    1024+0 records out
    1073741824 bytes transferred in 1.399918 secs (767003327 bytes/sec)
    ```

1. Set CF_API, CF_USER, CF_PASS, CF_SPACE, CF_ORG environmental variables

    ```
    $ export CF_API=https://api.cf-az.den.altoros.com
    $ export CF_USER=azalesov
    $ export CF_PASS=
    $ export CF_SPACE=dev1
    $ export CF_ORG=azalesov
    ```

1. Log in to the Cloud Foundry instance and target org/space

1. Create app-04 in another namespace

    ```
    $ cf target -s dev2
    api endpoint:   https://api.cf-az.den.altoros.com
    api version:    2.115.0
    user:           azalesov
    org:            azalesov
    space:          dev2

    $ cd challenges/04
    $ cf push
    $ cf target CF_SPACE
    ```