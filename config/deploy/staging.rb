server 'lib-solr-staging4d', user: 'deploy', roles: %{main}

# This must match the first half of a key in collections.yml,
# otherwise the backup process won't be able to find any
# collections to backup
set :whenever_host, ->{ "solr8" }
set :whenever_environment, ->{ "staging" }

def zk_host
  "lib-zk-staging1d:2181,lib-zk-staging2d:2181,lib-zk-staging3d:2181/solr8"
end

# config directory => config set name
def config_map
  {
    "catalog-production-v2" => "catalog-production-v2",
    "catalog-production-v3" => "catalog-production-v3",
    "dss-production" => "dss-production",
    "pulfalight-staging" => "pulfalight-staging",
    "cicognara" => "cicognara",
    "lae" => "lae",
    "dpul" => "dpul",
    "pdc-discovery" => "pdc-discovery-staging",
    "oawaiver" => "oawaiver-staging",
    "figgy" => "figgy-staging",
    "libwww" => "libwww",
    "pulmap" => "pulmap"
  }
end

def collections
  PulSolr.collections["solr8_staging"]
end
