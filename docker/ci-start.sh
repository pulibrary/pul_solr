#!/bin/bash

export SOLR_PORT=${SOLR_PORT:=8984}
export ZK_PORT=${ZK_PORT:=9984}
bin/solr start --cloud --no-prompt -p $SOLR_PORT
server/scripts/cloud-scripts/zkcli.sh -zkhost localhost:$ZK_PORT -cmd putfile /security.json /opt/solr/security.json
sleep infinity
