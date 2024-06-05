server 'lib-solr-staging1', user: 'deploy', roles: %{main}

# This must match the first half of a key in collections.yml,
# otherwise the backup process won't be able to find any
# collections to backup
set :whenever_host, ->{ "solr9" }
set :whenever_environment, ->{ "staging" }

def zk_host
  "lib-zk-staging4:2181,lib-zk-staging5:2181,lib-zk-staging6:2181/solr9"
end

# config directory => config set name
def config_map
  {
  #  "cdh_ppa" => "cdh_ppa",
  #  "geniza" => "geniza"
  }
end

def collections
  PulSolr.collections["solr9_staging"]
end
