#!/bin/bash

export SOLR_PORT=${SOLR_PORT:=8984}
bin/solr start --cloud --no-prompt -p $SOLR_PORT
server/scripts/cloud-scripts/zkcli.sh -zkhost localhost:$SOLR_PORT -cmd putfile /security.json /opt/solr/security.json
sleep infinity
