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

def solr_url
  ENV['SOLR_URL'] ||= 'http://localhost:8983/solr'
end


namespace :deploy do
  after :published, :restart do
    on roles(:main), wait: 5 do
      # on stand alone server just restart solr, no way to send information to zoo keeper since it does not exist
      if fetch(:stand_alone, false)
        on roles(:main) do
          execute "sudo /usr/sbin/service solr restart"
        end
      # on solr cloud, reload the configsets and collections
      else
        config_map.each { |key, val| update_configset(config_dir: key, config_set: val) }
        collections.each { |collection| reload_collection(collection) }
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

  # Swaps the catalog-rebuild and catalog-production aliases.
  # Production and rebuild collections are set with env variables when running the task.
  task :catalog do
    production = ENV['PRODUCTION']
    rebuild = ENV['REBUILD']
    if production && rebuild
      on roles(:main) do
        # Delete the rebuild alias
        execute "curl '#{solr_url}/admin/collections?action=DELETEALIAS&name=catalog-rebuild'"

        # Move the catalog-production alias
        execute "curl '#{solr_url}/admin/collections?action=CREATEALIAS&name=catalog-production&collections=#{production}'"

        # Add the rebuild alias to its new location
        execute "curl '#{solr_url}/admin/collections?action=CREATEALIAS&name=catalog-rebuild&collections=#{rebuild}'"
      end
    else
      puts "Please set the PRODUCTION and REBUILD environment variables. For example:"
      puts "cap production alias:catalog PRODUCTION=catalog-production2 REBUILD=catalog-production1"
    end
  end
end

namespace :configsets do
  def list_configsets
    execute "curl #{solr_url}/admin/configs?action=LIST&omitHeader=true"
  end

  def upload_configset(config_dir:, config_set:)
    execute "(cd #{File.join(release_path, config_dir)} && zip -r - *) | curl -X POST --header 'Content-Type:application/octet-stream' --data-binary @- '#{solr_url}/admin/configs?action=UPLOAD&name=#{config_set}'"
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

  desc 'Update a Configset'
  task :update, :config_dir, :config_set do |task_name, args|
    on roles(:main) do
      update_configset(config_dir: args[:config_dir], config_set: args[:config_set])
    end
  end

  desc 'Upload a Configset using a Solr config. directory'
  task :upload, :config_dir, :config_set do |task_name, args|
    on roles(:main) do
      upload_configset(config_dir: args[:config_dir], config_set: args[:config_set])
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
  def list_collections
    execute "curl '#{solr_url}/admin/collections?action=LIST'"
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
      list_collections
    end
  end

  desc 'Reload a Collection'
  task :reload, :collection do |task_name, args|
    on roles(:main) do
      reload_collection(args[:collection])
    end
  end

  desc 'Delete a Collection'
  task :delete, :collection do |task_name, args|
    on roles(:main) do
      delete_collection(args[:collection])
    end
  end
end
