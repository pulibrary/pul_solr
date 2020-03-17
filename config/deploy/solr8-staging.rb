server 'lib-solr-staging4', user: 'deploy', roles: %{main}

set :branch, ENV['BRANCH'] || 'master'

def zk_host
  "lib-zk-staging1:2181,lib-zk-staging2:2181,lib-zk-staging3:2181/solr8"
end

def config_map
  {
    "catalog-production" => "catalog-production",
    "catalog-staging" => "catalog-staging",
    "pulfalight-staging" => "pulfalight-staging",
    "reserves" => "reserves"
  }
end

def collections
  [
    'catalog-staging',
    'reserves',
    'dss-staging', # uses catalog configset
    'pulfalight-staging'
  ]
end
