server 'lib-solr-staging4d', user: 'deploy', roles: %{main}

# This is used to create part of the backup directory path
set :whenever_host, ->{ "solr8" }
set :whenever_environment, ->{ "staging" }

def zk_host
  "lib-zk-staging1d:2181,lib-zk-staging2d:2181,lib-zk-staging3d:2181/solr8"
end

# config directory => config set name
def config_map
  {
    "catalog-production-v2" => "catalog-production-v2",
    "dss-production" => "dss-production",
    "pulfalight-staging" => "pulfalight-staging",
    "cicognara" => "cicognara",
    "lae" => "lae",
    "dpul" => "dpul",
    "dpulc-staging" => "dpulc-staging",
    "pdc-discovery" => "pdc-discovery-staging",
    "oawaiver" => "oawaiver-staging",
    "figgy" => "figgy-staging",
    "pulmap" => "pulmap"
  }
end
