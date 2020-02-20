server 'lib-solr-staging4', user: 'deploy', roles: %{main}

set :branch, ENV['BRANCH'] || 'master'

def zk_host
  "lib-zk8-staging1:2181,lib-zk8-staging2:2181,lib-zk8-staging3:2181/solr8"
end

def config_map
  {
    "catalog-production" => "catalog-production",
    "catalog-staging" => "catalog-staging",
    "pulfalight-staging" => "pulfalight-staging"
  }
end

def collections
  [
    'catalog-production-backup',
    'catalog-staging',
    'catalog-test'
  ]
end
