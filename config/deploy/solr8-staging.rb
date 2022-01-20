server 'lib-solr-staging4', user: 'deploy', roles: %{main}

set :whenever_host, ->{ "solr8" }
set :whenever_environment, ->{ "staging" }

def zk_host
  "lib-zk-staging1:2181,lib-zk-staging2:2181,lib-zk-staging3:2181/solr8"
end

# config directory => config set name
def config_map
  {
    "catalog-production" => "catalog-production",
    "catalog-staging" => "catalog-staging",
    "pulfalight-staging" => "pulfalight-staging",
    "cicognara" => "cicognara",
    "lae" => "lae",
    "dpul" => "dpul",
    "pdc-discovery" => "pdc-discovery-staging",
    "oawaiver" => "oawaiver-staging",
    "figgy" => "figgy-staging"
  }
end

def collections
  PulSolr.collections["solr8_staging"]
end
