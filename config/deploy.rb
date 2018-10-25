require 'json'

set :application, 'pul_solr'
set :repo_url, 'https://github.com/pulibrary/pul_solr.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/solr/pul_solr'

set :filter, :roles => %w{main}

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  after :published, :restart do
    on roles(:main), wait: 5 do
      config_map = {
        "catalog-production" => "catalog-production",
        "catalog-staging" => "catalog-staging",
        "dpul" => "dpul",
        "figgy" => "figgy",
        "lae" => "lae",
        "pulmap" => "pulmap"
      }
      collections = [
        'dpul-production',
        'figgy',
        'lae',
        'catalog-production1',
        'catalog-production2',
        'pulmap',
        'catalog-staging',
        'pulmap-staging',
        'dpul-staging-core',
        'lae-blacklight-staging'
      ]
      config_map.each { |key, val| update_configset(config_dir: key, config_set: val) }
      collections.each { |collection| reload_collection(collection) }
    end
  end
end

namespace :alias do
  task :list do
    on roles(:main) do
      execute "curl 'http://localhost:8983/solr/admin/collections?action=LISTALIASES'"
    end
  end

  # Swaps the catalog-rebuild and catalog-production aliases.
  # Production and rebuild collections are set with env variables when running the task.
  task :catalog do
    production = ENV['PRODUCTION']
    rebuild = ENV['REBUILD']
    if production && rebuild
      on roles(:main) do
        # Delete the rebuild alias
        execute "curl 'http://localhost:8983/solr/admin/collections?action=DELETEALIAS&name=catalog-rebuild'"

        # Move the catalog-production alias
        execute "curl 'http://localhost:8983/solr/admin/collections?action=CREATEALIAS&name=catalog-production&collections=#{production}'"

        # Add the rebuild alias to its new location
        execute "curl 'http://localhost:8983/solr/admin/collections?action=CREATEALIAS&name=catalog-rebuild&collections=#{rebuild}'"
      end
    else
      puts "Please set the PRODUCTION and REBUILD environment variables. For example:"
      puts "cap production alias:catalog PRODUCTION=catalog-production2 REBUILD=catalog-production1"
    end
  end
end

def update_configset(config_dir:, config_set:)
  execute "cd /opt/solr/bin && ./solr zk -upconfig -d #{File.join(release_path, "solr_configs", config_dir)} -n #{config_set}"
end

def reload_collection(collection)
  execute "curl 'http://localhost:8983/solr/admin/collections?action=RELOAD&name=#{collection}'"
end
