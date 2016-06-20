# PulSolr

[![Circle CI](https://circleci.com/gh/pulibrary/pul_solr.svg?style=svg)](https://circleci.com/gh/pulibrary/pul_solr)

Versions:

* Ruby: 2.3.0
* Solr: 6.1.0
* solr_wrapper: 0.13.1
* rspec-solr: 2.0.0
* rspec: 3.4

To install run `bundle install`

## Usage

Solr must be running in order for rspec-solr specs to run.

```
rake solr:start
rspec
```

## Solr Home Directory

`solr_configs/` is configured to be the Solr home directory. Each application's Solr core configuration is a subdirectory of `solr_configs/`. Relevant Solr analysis library packages can be found within each core's `lib/` directory.

## Updating Solr

To upgrade the version of Solr, update the solr_wrapper config in the Rakefile. New Solr releases tend to be accompanied by new library packages. The analysis libraries can be upgraded by running the following rake task, which will copy the library packages from the Solr distribution into the Solr home directory:

```
rake pulsolr:lib
```