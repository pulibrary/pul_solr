server 'lib-solr-prod4', user: 'deploy', roles: %{main}

set :branch, ENV['BRANCH'] || 'master'

def zk_host
  "lib-zk1:2181,lib-zk2:2181,lib-zk3:2181/solr8"
end

def config_map
  {
    "catalog-production" => "catalog-production",
    "catalog-production-alt" => "catalog-production-alt",
    "reserves" => "reserves",
    "pulfalight-production" => "pulfalight-production",
    "cicognara" => "cicognara",
    "lae" => "lae"
  }
end

def collections
  PulSolr.collections["solr8_production"]
end
