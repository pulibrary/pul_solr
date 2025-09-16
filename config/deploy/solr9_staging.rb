server 'lib-solr-staging2.princeton.edu', user: 'deploy', roles: %{main}

# This is used to create part of the backup directory path
set :whenever_host, ->{ "solr9" }
set :whenever_environment, ->{ "staging" }

def zk_host
  "lib-zk-staging4.princeton.edu:2181,lib-zk-staging5.princeton.edu:2181,lib-zk-staging6.princeton.edu:2181"
end

# config directory => config set name
# The box will also have some configs from CDH.  They are not managed by capistrano, but
# are reloaded when we deploy.
def config_map
  {
    "catalog-production-v3" => "catalog-production-v3",
  }
end
