Load Generation Utility: loader
===============================

Loader is a load generation utility that just hammers the other bad actors
in this suite, on regular intervals, attempting to trigger or exacerbate
their bad behavior.

It is configured entirely off of environment variables, which take the form:

    LOAD_TEST_(thing)=(ms):(url)

For example:

    LOAD_TEST_MEM=240:https://unsuspecting-app.cfapps.io/stuff

will cause `loader` to issue a GET request for /stuff, every 240ms, or about
4 times a minute.  Frequency can be tuned up or down.  Just be careful.
