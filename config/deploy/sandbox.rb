server 'sandbox-solr1.lib.princeton.edu', user: 'deploy', roles: %{main}

# This is used to create part of the backup directory path
set :whenever_host, ->{ "solr8" }
set :whenever_environment, ->{ "sandbox" }

def zk_host
  "sandbox-zk1.lib.princeton.edu:2181,sandbox-zk2.lib.princeton.edu:2181,sandbox-zk3.lib.princeton.edu:2181/solr8"
end

# config directory => config set name
def config_map
  {
    "pdc-discovery" => "pdc-discovery-staging"
  }
end
