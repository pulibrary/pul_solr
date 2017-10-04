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
