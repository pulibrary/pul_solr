# 1. Rotation of config sets for orangelight catalog index

Date: 2021-04-07

## Status

Accepted

## Context

Sometimes we make a change to the catalog config set that will break search results if it's deployed without a new index already in place. In these cases the config set in use cannot be updated with this change and we have to deploy a different config set for the reindexing collection, which is then swapped in once it's fully populated.

## Decision

For most config changes we will continue updating and reloading the config set in production.

In the cases described above we will copy a new config set from the most recent production config set, incrementing the version suffix. Once the index is created and swapped in, the previously-used config set should be deleted.

## Consequences

* We will not maintain more than one production config set at a time, reducing the number of files required to make a change and the risk of files slipping out of sync.
* There will be a very slowly increasing number of config sets on zookeeper, for which there is no automated clean-up strategy in place. This should be slow enough as to not be a problem.
