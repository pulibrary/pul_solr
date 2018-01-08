# PulSolr

[![Circle CI](https://circleci.com/gh/pulibrary/pul_solr.svg?style=svg)](https://circleci.com/gh/pulibrary/pul_solr)

Versions:

* Ruby: 2.3.0
* Solr: 7.0.0
* solr_wrapper: 1.1.0
* rspec-solr: 2.0.0
* rspec: 3.6

To install run `bundle install`

## Usage

Solr must be running in order for rspec-solr specs to run.

```
rake solr:start
rspec
```

## Solr Home Directory

`solr_configs/` is configured to be the Solr home directory. Each application's Solr core configuration is a subdirectory of `solr_configs/`. Relevant Solr analysis library packages can be found within each core's `lib/` directory.

## Adding a new core

In practice, the home directory is at `solr/data`. The deploy scripts are designed for updating, not adding, cores. It is likely that solr config management process will be a topic of discussion soon. For now, if you're adding a new core you must create a directory for it in `solr/data`, then symlink the conf folder to the deployed folder. Finally, create the new core via the cli, e.g.:

`./solr create -c my-new-core`
