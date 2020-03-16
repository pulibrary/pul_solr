server 'lib-solr-prod4', user: 'deploy', roles: %{main}

set :branch, ENV['BRANCH'] || 'master'

def zk_host
  "lib-zk1:2181,lib-zk2:2181,lib-zk3:2181/solr8"
end

def config_map
  {
    "catalog-production" => "catalog-production",
    "catalog-staging" => "catalog-staging",
    "reserves" => "reserves"
  }
end

def collections
  [
    'catalog-production1',
    'catalog-production2',
    'dss-production', # uses catalog-production config set
    'reserves'
  ]
end
