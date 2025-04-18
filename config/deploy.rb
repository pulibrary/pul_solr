require 'json'
require_relative '../lib/pul_solr'

set :application, 'pul_solr'
set :repo_url, 'https://github.com/pulibrary/pul_solr.git'

# Default branch is :main
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, ENV['BRANCH'] || 'main'

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

def solr_url
  ENV['SOLR_URL'] ||= 'http://localhost:8983/solr'
end

def list_collections
  body = capture "curl '#{solr_url}/admin/collections?action=LIST'"
  json = JSON.parse(body)
  json["collections"]
end

namespace :deploy do
  desc "Generate the crontab tasks using Whenever"
  after :published, :whenever do
    on roles(:main) do
      within release_path do
        execute("cd #{release_path} && bundle exec whenever --set 'environment=#{fetch(:whenever_environment, "production")}&host=#{fetch(:whenever_host, "test-host")}' --update-crontab pul_solr")
      end
    end
  end

  desc "Update configsets and reload collections"
  after :published, :restart do
    on roles(:main), wait: 5 do
      # make it a no-op for servers deployed with the cdh method
      next if config_map.empty?
      # on stand alone server just restart solr, no way to send information to zoo keeper since it does not exist
      if fetch(:stand_alone, false)
        on roles(:main) do
          execute "sudo /usr/sbin/service solr restart"
        end
      # on solr cloud, reload the configsets and collections
      else
        config_map.each { |key, val| update_configset(config_dir: key, config_set: val) }
        list_collections.each { |collection| reload_collection(collection) }
      end
    end
  end
end

namespace :alias do
  task :list do
    on roles(:main) do
      execute "curl '#{solr_url}/admin/collections?action=LISTALIASES'"
    end
  end

  # Swaps the rebuild and production catalog aliases.
  # Production and rebuild collections are set with env variables when running the task.
  task :swap do
    production = ENV['PRODUCTION']
    rebuild = ENV['REBUILD']
    production_alias = ENV['PRODUCTION_ALIAS'] || "catalog-alma-production"
    rebuild_alias = ENV['REBUILD_ALIAS'] || "catalog-alma-production-rebuild"
    if production && rebuild
      on roles(:main) do
        # Delete the rebuild alias
        execute "curl '#{solr_url}/admin/collections?action=DELETEALIAS&name=#{rebuild_alias}'"

        # Move the production alias
        execute "curl '#{solr_url}/admin/collections?action=CREATEALIAS&name=#{production_alias}&collections=#{production}'"

        # Create the rebuild alias
        execute "curl '#{solr_url}/admin/collections?action=CREATEALIAS&name=#{rebuild_alias}&collections=#{rebuild}'"
      end
    else
      puts "Please set the PRODUCTION and REBUILD environment variables. Optionally, set PRODUCTION_ALIAS and REBUILD_ALIAS as well. For example:"
      # Set PRODUCTION the collection name that is going to be in production.
      # Set REBUILD the collection name that is in production until the swap and moving forward is going to be in rebuild.
      # To know the current collection names for PRODUCTION and REBUILD see Solr UI -> collections. The following is an example.
      puts "PRODUCTION=catalog-alma-production2 REBUILD=catalog-alma-production3 cap production alias:swap"
      puts "PRODUCTION=catalog-staging2 REBUILD=catalog-staging1 PRODUCTION_ALIAS=catalog-staging REBUILD_ALIAS=catalog-staging-rebuild cap production alias:swap"
    end
  end
end

namespace :configsets do
  def list_configsets
    execute "curl #{solr_url}/admin/configs?action=LIST&omitHeader=true"
  end

  def update_configset(config_dir:, config_set:)
    execute "cd /opt/solr/bin && ./solr zk -upconfig -d #{File.join(release_path, "solr_configs", config_dir)} -n #{config_set} -z #{zk_host}"
  end

  def delete_configset(config_set)
    execute "curl \"#{solr_url}/admin/configs?action=DELETE&name=#{config_set}&omitHeader=true\""
  end

  desc 'List all Configsets'
  task :list do |task_name, args|
    on roles(:main) do
      list_configsets
    end
  end

  desc 'Update or create a Configset'
  task :update, :config_dir, :config_set do |task_name, args|
    on roles(:main) do
      update_configset(config_dir: args[:config_dir], config_set: args[:config_set])
    end
  end

  desc 'Delete a Configset'
  task :delete, :config_set do |task_name, args|
    on roles(:main) do
      delete_configset(args[:config_set])
    end
  end
end

namespace :collections do
  def create_collection(collection, config_name, num_shards = 1, replication_factor = 1, shards_per_node = 1)
    execute "curl '#{solr_url}/admin/collections?action=CREATE&name=#{collection}&collection.configName=#{config_name}&numShards=#{num_shards}&replicationFactor=#{replication_factor}&maxShardsPerNode=#{shards_per_node}'"
  end

  def reload_collection(collection)
    execute "curl '#{solr_url}/admin/collections?action=RELOAD&name=#{collection}'"
  end

  def delete_collection(collection)
    execute "curl '#{solr_url}/admin/collections?action=DELETE&name=#{collection}'"
  end

  desc 'List Collections'
  task :list do
    on roles(:main) do
      puts list_collections
    end
  end

  desc 'Reload a Collection'
  task :reload, :collection do |task_name, args|
    on roles(:main) do
      reload_collection(args[:collection])
    end
  end

  desc 'Create a Collection'
  # usage example: bundle exec cap staging collections:create[dpul-staging,dpul,1,3,1]
  task :create, :collection, :config_name, :num_shards, :replication_factor, :shards_per_node do |task_name, args|
    on roles(:main) do
      num_shards = args[:num_shards] || 1
      replication_factor = args[:replication_factor] || 1
      shards_per_node = args[:shards_per_node] || 1
      create_collection(args[:collection], args[:config_name], num_shards, replication_factor, shards_per_node)
    end
  end

  desc 'Delete a Collection'
  task :delete, :collection do |task_name, args|
    on roles(:main) do
      delete_collection(args[:collection])
    end
  end
end

namespace :solr do
  desc "Opens Solr Console"
  task :console do
    on roles(:main) do |host|
      solr_host = host.hostname
      user = "pulsys"
      port = rand(9000..9999)
      puts "Opening #{solr_host} Solr Console on port #{port} as user #{user}"
      Net::SSH.start(solr_host, user) do |session|
        session.forward.local(port, "localhost", 8983)
        puts "Press Ctrl+C to end Console connection"
        `open http://localhost:#{port}`
        session.loop(0.1) { true }
      end
    end
  end
end
