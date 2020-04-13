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

Note that `solr.xml` is used for development and testing on this repository, but not in production. The production file is at https://github.com/pulibrary/princeton_ansible/blob/master/roles/pulibrary.solrcloud/templates/solr.xml.j2

## Solr Inventory

Current solr machines and their collections are enumerated in the [solr
inventory](https://docs.google.com/spreadsheets/d/118O7JeVEPaoVsCIxoWLdDTctcTCe4CGaHChjN6yorgc/edit#gid=0).

## Adding a new core

This repository updates, but does not create, collections. To add a new collection, create its config here and deploy to get the config up to the server. Then use the UI to create the collection (TODO: how to make the config set available to the UI?). Finally, you can add the collection to the deploy scripts so that it will be updated in future deployments.

## Managing Configsets

*After deploying* one may list, upload, update, and delete Configsets using the following Capistrano tasks:
```
SOLR_URL=http://localhost:8983/solr bundle exec cap development configsets:list
SOLR_URL=http://localhost:8983/solr bundle exec cap development configsets:upload[solr_configs/dpul/conf,dpul-config]
SOLR_URL=http://localhost:8983/solr bundle exec cap development configsets:update[solr_configs/dpul_new/conf,dpul-config]
SOLR_URL=http://localhost:8983/solr bundle exec cap development configsets:delete[dpul-config]
```

Please note that, when uploading a directory for a new Configset from this repository, that the `/conf` subdirectory should be used (e. g. `solr_configs/dpul/conf`)

## Managing Collections

Using Capistrano, one may create, reload, delete, and list Collections using the following tasks:
```
SOLR_URL=http://localhost:8983/solr bundle exec cap development collections:list
SOLR_URL=http://localhost:8983/solr bundle exec cap development collections:create[dpul,dpul-config]
SOLR_URL=http://localhost:8983/solr bundle exec cap development collections:reload[dpul]
SOLR_URL=http://localhost:8983/solr bundle exec cap development collections:delete[dpul]
```

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

### Heap Dump

If you have no idea what is happening on solr you may want to try dumping the
heap. This is difficult when GC is freezing everything. Keep trying and
eventually you may be lucky!

Run as deploy user:
`jmap -dump:format=b,file=/home/deploy/solr.hprof [pid_of_solr_process]`

Then you'll want to look at it. Download the file to your machine
`scp deploy@lib-solrN:/home/deploy/solr.hprof .`

Download and install the [eclipse memory analyzer](https://www.eclipse.org/mat/downloads.php) application.

You need to assign enough heap to the app to hold the entire heap that you
dumped on the server. When you unzip it you get a `mat` directory. Right click
and select "Show Package Contents", then expand contents > eclipse > right click
on "MemoryAnalyzer.ini" to edit. Change "-Xmx" to be a number bigger than the
file you have.

You're supposed to be able to double-click the 'mat' file but that doesn't work.
you have to "Show Package Contents" > Contents > MacOS > run 'MemoryAnalyzer'

Congratulations! You opened the application. Now open the heap file and wait a
long time while it parses the file and the progress bar jumps around. It took
about an hour for a 20g file for us.

You want to look at the dominator tree to see how much heap is used by each
object. Right-click the biggest one's thread (higher in the tree) > Java Basics > Thread Overview and Stacks. Expand the thread click the "total" button at the bottom so all of them will open up. Expand the first column (Object stack frame). Expand 'org.eclipse.jetty.servlet.ServletHandler.doHandle'. Click the first (local) frame. Look on the left, double-click the + to expand more properties, the thing that broke it was `_originalURI`. right-click > copy value.
