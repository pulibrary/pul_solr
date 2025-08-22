#!/bin/bash

bin/solr start --cloud --no-prompt -p 8984
server/scripts/cloud-scripts/zkcli.sh -zkhost localhost:9984 -cmd putfile /security.json /opt/solr/security.json
sleep infinity
