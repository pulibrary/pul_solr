# 4. Revert memory tuning

Date: 2020-01-16

## Status

Accepted

## Context

We experimentally changed the GC settings for lib-solr1 (see ADR 0003). The
result is that the heap grows quite large, right up to the limit, before going
into GC. We aren't comfortable with letting the heap get so large.

Heap sizes don't grow as much on the other solr machines, and we also are not seeing the
OutOfMemoryErrors we had been observing when we initiated this change on
lib-solr1. Settings on the other machines are mostly pulled from the [default solr
recommendations](https://github.com/apache/lucene-solr/blob/5f2d7c4855987670489d68884c787e4cfb377fa9/solr/bin/solr.in.sh#L48-L62).

## Decision

Revert the memory tuning on lib-solr1 to match those on the other machines.

## Consequences

* Heap on lib-solr1 will be garbage collected before reaching the
  near-maximum size.
* Heap behavior on lib-solr1 will match the behavior on the other prod solr
  machines.
