# Some Badly-Behaving Appliations

These applications are part of the machinery used for the Cloud
Foundry North America Summit 2018, held in Boston.

## cache-api

The Caching API application provides on-demand, caching of some
unidentified _expensive_ backend process.  It differs from a
generic cache / key-value store like Redis in that the cache-api
generates the thing that it caches, and the caching is a
performance tweak.

The problem with `cache-api` is that it runs for a while and then
falls over, losing all of its cache.  This is causing undue stress
on the backend systems, since the same _expensive_ operations are
repeated over and over again.

This just won't do.

## fulfil-api

The Fulfillment API application provides a modern REST-based
front-end to a legacy warehousing and fulfillment service.  It
works pretty well, functionally speaking, but it does have some
availability issues; seems like it regularly falls over, and even
though Cloud Foundry does an admirable job of resurrecting it,
there is a slight gap in service availability.

We'd like to avoid that.

## loadgen

The `loadgen` application exists to enable the labs to maintain
the illusion that these bad actors are taking load.  Refer to its
README.md for the nitty-gritty.
