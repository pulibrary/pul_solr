server 'lib-solr-prod1.princeton.edu', user: 'deploy', roles: %{main}

set :whenever_host, ->{ "solr9" }
set :whenever_environment, ->{ "production" }

def zk_host
  "lib-zk4:2181,lib-zk5:2181,lib-zk6:2181"
end

# config directory => config set name
# This should be empty if there are only cdh things on the box
def config_map
  {
    "catalog-production-v3" => "catalog-production-v3",
  }
end
