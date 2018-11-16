# 3. Remove memory tuning

Date: 2018-11-14

## Status

Accepted

## Context

We have seen a number of OutOfMemoryErrors with Solr, mostly related to garbage collection.  Our memory
settings include many overrides of the defaults, and it's not clear what they do individually or as a group.
These settings have also been in use for several years, and we're not sure if they are still a good match for
our hardware and usage.

## Decision

Remove the following memory tuning options from the Java options:
* `-Xss=256k`
* `-XX:NewRatio=3`
* `-XX:SurvivorRatio=4`
* `-XX:TargetSurvivorRatio=90`
* `-XX:MaxTenuringThreshold=8`
* `-XX:ConcGCThreads=4`
* `-XX:ParallelGCThreads=4`
* `-XX:PretenureSizeThreshold=64m`
* `-XX:CMSInitiatingOccupancyFraction=50`
* `-XX:CMSMaxAbortablePrecleanTime=6000`

Add the following option to disable throwing an OutOfMemoryError if garbage collection takes too long:
* `-XX:-UseGCOverheadLimit`

Decrease total memory allocation from 72 GB to 40 GB.

## Consequences

* Not throwing an OutOfMemoryError may result in Java hanging instead of throwing an error, which would hide
  the problem instead of notifying us.
* Removing the memory tuning options may make our garbage collection problems worse, if those parameters are
  in fact still good.
* Reducing the memory allocation will trigger garbage collection more frequently, but it should also make it
  faster at the same time.
