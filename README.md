# PulSolr

Versions:

* Ruby: 2.3.0
* Solr: 5.4.1
* solr_wrapper: 0.6.1 (until https://github.com/cbeer/solr_wrapper/issues/44 is resolved)
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

`configs/` is configured to be the Solr home directory. Each application's Solr core configuration is a subdirectory of `configs/`. Relevant Solr analysis library packages can be found under `configs/lib`.

## Updating Solr

To upgrade the version of Solr, update the `.solr_wrapper` configuration file. New Solr releases tend to be accompanied by new library packages. The analysis libraries can be upgraded by running the following rake task, which will copy the library packages from the Solr distribution into the Solr home directory:

```
rake pulsolr:lib
```