server 'lib-solr-staging1', user: 'deploy', roles: %{main}

# This is used to create part of the backup directory path
set :whenever_host, ->{ "solr9" }
set :whenever_environment, ->{ "staging" }

def zk_host
  "lib-zk-staging4.princeton.edu:2181,lib-zk-staging5.princeton.edu:2181,lib-zk-staging6.princeton.edu:2181"
end

# config directory => config set name
# This should be empty if there are only cdh things on the box
def config_map
  { }
end
