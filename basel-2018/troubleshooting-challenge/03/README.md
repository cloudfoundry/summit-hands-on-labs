Route conflict
==============

Error
-----

```
Getting app info...
The app cannot be mapped to route bazel-04.cf-az.den.altoros.com because the route exists in a different space.
FAILED
```

Hints
-----

1. Does the app with the same name in the same namespace?

    ```
    cf apps
    Getting apps in org azalesov / space dev1 as azalesov...
    OK

    name       requested state   instances   memory   disk   urls
    bazel      started           1/1         1G       1G     bazel.cf-az.den.altoros.com
    bazel-01   started           1/1         1G       1G     bazel-01.cf-az.den.altoros.com
    bazel-03   started           1/1         1G       1G     bazel-03.cf-az.den.altoros.com
    ```

1. List routes in the org:

    ```
    $ cf routes --orglevel
    Getting routes for org azalesov as azalesov ...

    space   host       domain                  port   path   type   apps       service
    dev1    bazel      cf-az.den.altoros.com                        bazel
    dev1    bazel-01   cf-az.den.altoros.com                        bazel-01
    dev1    bazel-03   cf-az.den.altoros.com                        bazel-03
    dev2    bazel-04   cf-az.den.altoros.com                        bazel-04
    ```

Solution
---------

1. Tell app to use randomly generated route

    ```
    + random-route: true
    ```