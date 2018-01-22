# PulSolr

[![Circle CI](https://circleci.com/gh/pulibrary/pul_solr.svg?style=svg)](https://circleci.com/gh/pulibrary/pul_solr)

Versions:

* Ruby: 2.3.0
* Solr: 7.0.0
* solr_wrapper: 1.1.0
* rspec-solr: 2.0.0
* rspec: 3.6

To install run `bundle install`

## Solr Home Directory

`solr_configs/` is configured to be the Solr home directory. Each application's Solr core configuration is a subdirectory of `solr_configs/`. Relevant Solr analysis library packages can be found within each core's `lib/` directory.

## Adding a new core

In practice, the home directory is at `solr/data`. The deploy scripts are designed for updating, not adding, cores. It is likely that solr config management process will be a topic of discussion soon. For now, if you're adding a new core you must create a directory for it in `solr/data`, then symlink the conf folder to the deployed folder. Finally, create the new core via the cli, e.g.:

`./solr create -c my-new-core`

## Specs

Solr must be running in order for rspec-solr specs to run.

```
rake solr:start
rspec
```

### Fixtures

To get fixtures for specs, you can't just pull json documents out of existing solr cores because then you won't get the index-only fields. You can get most records at the bibdata path, e.g. `https://bibdata.princeton.edu/bibliographic/10166399/solr`

If you need a scsb record, you have to go on the bibdata worker box, look in `/data/scsb_temp`, and grep for the id you want, e.g.

`grep -r SCSB-3330744 .`

Copy the line you found into a `.xml` file in your local copy of marc_liberation. Then grab the first two lines from the file in which you found that record, e.g.

`head -n2 scsbupdate20171226_030300_19.xml`

Copy those as the first two lines in your `.xml` file.

Then get the indexed json with the following command in the marc_liberation file:
`bundle exec traject -c marc_to_solr/lib/traject_config.rb -t xml scsb.xml -w Traject::JsonWriter`

Finally, copy the output and paste it into a fixture file in your pul_solr project. It's nice to fix the formatting of the json; in vim you can do this with a little python utility ala `:%!python -m json.tool`
