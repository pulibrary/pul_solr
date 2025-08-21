# Compiling Solr Jars

## Requirements

* A recent version of the JDK (Tested on Java 21.0.2)
* Maven (Tested on 3.9.9)

## CJKFoldingFilter/CJKFilterUtils
The CJKFoldingFilter jar is now contained in the [CJKFilterUtils repo](https://github.com/sul-dlss/CJKFilterUtils) at Stanford

1. Clone the repo
2. Run `mvn install`
3. The jar will be located in the target folder.


## umich_solr_library_filters
The University of Michigan Solr Filters are located in the [repo](https://github.com/mlibrary/umich_solr_library_filters), but it is outdated. There is a PR with the [updated code](https://github.com/trln/umich_solr_library_filters/tree/lucene-9-migration) for Solr 9.


1. Either clone the [forked repo](https://github.com/trln/umich_solr_library_filters) and checkout the [updated branch](https://github.com/trln/umich_solr_library_filters/tree/lucene-9-migration), or clone the [upstream repo](https://github.com/mlibrary/umich_solr_library_filters) and add the fork to the remotes to checkout the branch.
2. Run `mvn package`
3. The jar will be located in the target folder.
