# 2. Increase ZooKeeper timeout

Date: 2018-11-14

## Status

Accepted

## Context

A ZooKeeper timeout last night brought several Solr servers down. Factors that might make servers unresponsive
are garbage collection, network traffic/latency, and high amounts of disk I/O.

## Decision

Increase the ZooKeeper timeout from 15 seconds to 60 seconds.

## Consequences

The higher the timeout, the more out of sync nodes may become before failure is detected. The Orangelight
index has had the most problems, and it has much more search activity than indexing activity, which mitigates
this risk.
