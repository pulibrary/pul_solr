# PulSolr

[![Circle CI](https://circleci.com/gh/pulibrary/pul_solr.svg?style=svg)](https://circleci.com/gh/pulibrary/pul_solr)

Dependencies

* see .tool-versions for language dependencies
* SolrCloud machines are running Solr 8.4.1

To install run `bundle install`

## Solr Home Directory

`solr_configs/` is configured to be the Solr home directory. Each application's Solr core configuration is a subdirectory of `solr_configs/`. Relevant Solr analysis library packages can be found within each core's `lib/` directory.

Note that `solr.xml` is used for development and testing on this repository, but not in production. The production file is at https://github.com/pulibrary/princeton_ansible/blob/master/roles/pulibrary.solrcloud/templates/solr.xml.j2

## SolrCloud Inventory

Current SolrCloud machines and their collections are enumerated in the [solr
inventory](https://docs.google.com/spreadsheets/d/118O7JeVEPaoVsCIxoWLdDTctcTCe4CGaHChjN6yorgc/edit#gid=0).

## Adding a new core

This repository updates, but does not create, collections. To add a new collection:
- add the new collection's configuration to this project's `solr_configs` directory
- add the new solr configuration location and config set name to the `config_map` in the relevant `/config/deploy/<env>.rb` file so it will be uploaded to zookeeper
- deploy to get the config up to the server
- use the UI to create the collection
- all collections are reloaded each time this project is deployed

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

Backups are implemented as a ruby service class wrapped in a rake task that's invoked by cron (scheduled via whenever / capistrano). The task queries solr for the list of collections and then backs up each one.

If a specific backup did not complete and you want more information, consult `/tmp/solr_backup.log` for the request id and check it with the [requeststatus api call](https://lucene.apache.org/solr/guide/8_4/collections-api.html#requeststatus). Example:

```
curl "http://localhost:8983/solr/admin/collections?action=REQUESTSTATUS&requestid=figgy-production-202501132037"
```

### Restoring a backup

Before restoring:
1. Check the size of your backup with `du -sh`.  For example, if your backup is /mnt/solr_backup/solr8/production/20240606/catalog-alma-production3-20240606.bk:
    
    ```
    /mnt/solr_backup/solr8/production/20240606/catalog-alma-production3-20240606.bk
    ```
    
1. Check the size of the root file system on the machine on which you are performing the restore: `df -h`.
1. If there is not enough storage on the root file system for the backup, resolve
   that issue before proceeding.

Restoring a backup ([solr docs](https://lucene.apache.org/solr/guide/8_4/collection-management.html#restore)) is a matter of issuing the proper API call on the solr box, e.g.:

```
$ curl "http://localhost:8983/solr/admin/collections?action=RESTORE&name=pulfalight-staging-20210111.bk&collection=pulfalight-staging-restore&location=/mnt/solr_backup/staging/20210111"
```

To find the right values for this curl:

1. SSH with a tunnel to a solr box (for example, `ssh -L 8983:localhost:8983 deploy@lib-solr-staging5d`)
1. Run `ls -t /mnt/solr_backup/solr8/production` if you want to restore from
   a production backup, or `ls -t /mnt/solr_backup/solr8/staging` if you want
   to restore from a staging backup.  The first directory will be the most
   recent backup.
    * The **location** parameter will be `/mnt/solr_backup/solr8/{Environment}/{Backup Date}`.  In the example above, it is `/mnt/solr_backup/staging/20210111`
1. Do an `ls` of the directory that you will use as the location parameter.  
   For example, `ls /mnt/solr_backup/staging/20210111`.
    * The **name** parameter will be the directory name of the collection you want to restore.  In the example above, it is `pulfalight-staging-20210111.bk`, referring to the `/mnt/solr_backup/staging/20210111/pulfalight-staging-20210111.bk` directory.
1. Choose a name for a new collection you'd like to restore the data into.
   In your browser, go to http://localhost:8983/solr/#/~collections and
   confirm that there is not already a collection by that name.
    * The **collection** parameter will be the name of the collection.
1. If the collection is very large (e.g. the catalog), the restore will
   probably time out.  You can still move forward by adding the
   [**async** parameter](https://solr.apache.org/guide/8_4/collections-api.html#asynchronous-calls).
   It should be something unique to this particular restore.
1. Run the curl with the location, name, collection, and -- if the collection
   is large -- async parameters you determined above.

If you ran this with an async ID in the **async** param, you can check
the progress in your browser at: `http://localhost:8983/solr/admin/collections?action=REQUESTSTATUS&requestid={your async id}`

## Specs

Start Solr via lando, then run the specs.

If you are making changes to a file in the solr_configs directory, such as a schema.xml or solrconfig.xml file, you will need to restart lando after each change in order for it to be picked up by the tests.

```
lando start
rspec
<!-- make some change -->
lando restart
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
