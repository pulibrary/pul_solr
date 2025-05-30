server 'lib-solr-prod7.princeton.edu', user: 'deploy', roles: %{main}

set :whenever_host, ->{ "solr8" }
set :whenever_environment, ->{ "production" }

def zk_host
  "lib-zk-prod1:2181,lib-zk-prod2:2181,lib-zk-prod3:2181/solr8"
end

# config directory => config set name
def config_map
  {
    "catalog-production-v2" => "catalog-production-v2",
    "dss-production" => "dss-production",
    "pulfalight-production" => "pulfalight-production",
    "cicognara" => "cicognara",
    "lae" => "lae",
    "pdc-discovery" => "pdc-discovery-production",
    "oawaiver" => "oawaiver-production",
    "figgy" => "figgy-production",
    "dpul" => "dpul",
    "pulmap" => "pulmap"
  }
end
