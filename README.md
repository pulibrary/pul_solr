# PulSolr

[![Circle CI](https://circleci.com/gh/pulibrary/pul_solr.svg?style=svg)](https://circleci.com/gh/pulibrary/pul_solr)

Dependencies

* Ruby: 2.6.5

SolrCloud machines are running Solr 8.4.1

To install run `bundle install`

## Solr Home Directory

`solr_configs/` is configured to be the Solr home directory. Each application's Solr core configuration is a subdirectory of `solr_configs/`. Relevant Solr analysis library packages can be found within each core's `lib/` directory.

Note that `solr.xml` is used for development and testing on this repository, but not in production. The production file is at https://github.com/pulibrary/princeton_ansible/blob/master/roles/pulibrary.solrcloud/templates/solr.xml.j2

## SolrCloud Inventory

Current SolrCloud machines and their collections are enumerated in the [solr
inventory](https://docs.google.com/spreadsheets/d/118O7JeVEPaoVsCIxoWLdDTctcTCe4CGaHChjN6yorgc/edit#gid=0).

## Adding a new core

This repository updates, but does not create, collections. To add a new collection, create its config here and deploy to get the config up to the server. Then use the UI to create the collection. Finally, you can add the collection to the deploy scripts so that it will be updated in future deployments (https://github.com/pulibrary/pul_solr/blob/main/config/collections.yml).

**Note: Each collection should be created with a replication factor of 2 at minimum.**

### Connecting to Solr UI
There are capistrano tasks to connect to the Solr UI for managing solr that can be run from the project directory on your machine.  You will need to be connected to VPN for the tasks to run.
 * Production Solr 8
   ```
   bundle exec cap production solr:console
   ```

 * Staging Solr 8
   ```
   bundle exec cap staging solr:console
   ```

 * Staging Solr 8d
   ```
   bundle exec cap staging_new solr:console
   ```

## Managing Orangelight Catalog Configsets

When we need to make a change to the orangelight config set that would break
search we need to deploy a new config set, index with it, and then swap it in
and retire the previous config set. See ADR#0005 for more details. In this case
the following procedure should be followed:

1. Copy the current production config set into a new directory, incrementing the
   version number. Change the name of the core in core.properties in the old
   config set so the new one is used for testing.
1. Deploy the new config set
1. Delete the solr collection in use for indexing. Recreate it using the new config set.
1. Populate the reindex collection
1. Swap the alias so the reindex collection becomes the production / in-use
   collection
1. Delete the old collection and re-create it using the new config set
1. Delete the old config set from this repository

## Managing Configsets

*After deploying* one may list, upload, update, and delete Configsets using the following Capistrano tasks:
```
SOLR_URL=http://localhost:8983/solr bundle exec cap development configsets:list
SOLR_URL=http://localhost:8983/solr bundle exec cap development "configsets:update[dpul_new/conf,dpul-config]"
SOLR_URL=http://localhost:8983/solr bundle exec cap development "configsets:delete[dpul-config]"
```

Please note that, when uploading a directory for a new Configset from this repository, that the `/conf` subdirectory should be used (e. g. `dpul/conf`)

## Managing Collections

Using Capistrano, one may create, reload, delete, and list Collections using the following tasks:
```
SOLR_URL=http://localhost:8983/solr bundle exec cap development collections:list
SOLR_URL=http://localhost:8983/solr bundle exec cap development "collections:create[dpul,dpul-config]"
SOLR_URL=http://localhost:8983/solr bundle exec cap development "collections:reload[dpul]"
SOLR_URL=http://localhost:8983/solr bundle exec cap development "collections:delete[dpul]"
```

## SolrCloud Backups

Backups are implemented as a ruby service class wrapped in a rake task that's invoked by cron (scheduled via whenever / capistrano)

If a specific backup did not complete and you want more information, consult the log for the requeststatus and check it with the [requeststatus api call](https://lucene.apache.org/solr/guide/8_4/collections-api.html#requeststatus).

Restoring a backup ([solr docs](https://lucene.apache.org/solr/guide/8_4/collection-management.html#restore)) is a matter of issuing the proper API call on the solr box, e.g.:

```
$ curl "http://localhost:8983/solr/admin/collections?action=RESTORE&name=pulfalight-staging-20210111.bk&collection=pulfalight-staging-restore&location=/mnt/solr_backup/staging/20210111"
```

## Specs

Start Solr via lando, then run the specs

```
lando start
rspec
```

To stop Solr again do `lando stop`

### Fixtures

To get fixtures for specs, you can't just pull json documents out of existing solr cores because then you won't get the index-only fields.

#### Orangelight fixtures

You can get most records at the bibdata path, e.g. `https://bibdata.princeton.edu/bibliographic/10166399/solr`

If you need a scsb record, you have to go on the bibdata worker box, look in `/data/scsb_temp`, and grep for the id you want, e.g.

`grep -r SCSB-3330744 .`

Copy the line you found into a `.xml` file in your local copy of marc_liberation. Then grab the first two lines from the file in which you found that record, e.g.

`head -n2 scsbupdate20171226_030300_19.xml`

Copy those as the first two lines in your `.xml` file.

Then get the indexed json with the following command in the marc_liberation file:
`bundle exec traject -c marc_to_solr/lib/traject_config.rb -t xml scsb.xml -w Traject::JsonWriter`

Finally, copy the output and paste it into a fixture file in your pul_solr project. It's nice to fix the formatting of the json; in vim you can do this with a little python utility ala `:%!python -m json.tool`

#### Pulfalight fixtures

In pulfalight we are pulling fixture documents straight from solr, which means
we can't test against fields that are indexed but not stored. Pull a fixture
like, e.g.:

```
http://localhost:8983/solr/pulfalight-dev/select?id=MC001-02-03&qt=document
```

### Heap Dump

If you have no idea what is happening on solr you may want to try dumping the
heap. This is difficult when GC is freezing everything. Keep trying and
eventually you may be lucky!

1. Run as pulsys user:

        sudo nsenter -t [pid_of_solr_process] -m # Enter the namespace of the Solr PID, so that systemd security settings don't block the dump
        sudo su - deploy # jmap must be run as the same user as solr
        jmap -dump:format=b,file=/home/deploy/solr.hprof [pid_of_solr_process]

1. Then you'll want to look at it. Download the file to your machine

        scp deploy@lib-solrN:/home/deploy/solr.hprof .

1. Download and install the [eclipse memory analyzer](https://www.eclipse.org/mat/downloads.php) application.

1. You need to assign enough heap to the app to hold the entire heap that you
dumped on the server. When you unzip it you get a `mat` directory:

    1. After installing the Memory Analyzer, open the
    Applications directory in Finder.
    1. Right click on Memory Analyzer and select "Show Package Contents"
    1. expand contents > eclipse > right click
    on "MemoryAnalyzer.ini" to edit.
    1. Change "-Xmx" to be a number bigger than the
    file you have.

1. You're supposed to be able to double-click the 'mat' file but that doesn't work.
you have to "Show Package Contents" > Contents > MacOS > run 'MemoryAnalyzer'

1. Congratulations! You opened the application. Now open the heap file and wait a
long time while it parses the file and the progress bar jumps around. It took
about an hour for a 20g file for us.

1. You want to look at the dominator tree to see how much heap is used by each
object. Right-click the biggest one's thread (higher in the tree) > Java Basics > Thread Overview and Stacks. Expand the thread click the "total" button at the bottom so all of them will open up. Expand the first column (Object stack frame). Expand 'org.eclipse.jetty.servlet.ServletHandler.doHandle'. Click the first (local) frame. Look on the left, double-click the + to expand more properties, the thing that broke it was `_originalURI`. right-click > copy value.

## Solr Docker
The docker directory contains a Dockerfile that serves as the base docker image for running Solr in CI and Lando.

This image:
- adds a security.json which allows us to make changes to solr via basic auth. It runs with an embedded zookeeper on a separate port.
- adds Solr plugins downloaded from the solrcloud role in princeton_ansible
- contains scripts for solr setup in circleci and lando.

### Update and Rebuild
### quay.io
This is Red Hat's container registry (they also call it a repository), and where Ops is shifting to keeping images (as of May 2023). Contact the Ops team to become a member of [the pulibrary organization](https://quay.io/organization/pulibrary). You must be a member in order to push an image to the remote repository.

Building and pushing an image:

```bash
cd docker/
docker login quay.io # login to quay.io
docker buildx create --use # only necessary the first time you want to build an image
docker buildx build --platform linux/arm64/v8,linux/amd64 -t quay.io/pulibrary/ci-solr:{solr version}-{Dockerfile version} --push .
```

For example, if you are building with solr 8.4 and Dockerfile 1.0.0:

```bash
cd docker/
docker login # login to quay.io
docker buildx create --use
docker buildx build --platform linux/arm64/v8,linux/amd64 -t qay.io/pulibrary/ci-solr:8.4-v1.0.0 --push .
```

### Github Container Registry
You can also push to your own Github Container Registry, if you are just testing something out:

1. [Login to the container registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
1. `cd docker`
2. `docker buildx create --use # only necessary the first time`
3. `docker buildx build --platform linux/arm64/v8,linux/amd64 -t ghcr.io/[username]/ci-solr:{solr version}-{Dockerfile version} --push .`

### Docker hub - deprecated
Old images were pushed to the pulibrary docker hub organization - for older tags see https://hub.docker.com/r/pulibrary/ci-solr/tags
