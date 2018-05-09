require 'json'

set :application, 'pul_solr'
set :repo_url, 'https://github.com/pulibrary/pul_solr.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/solr/pul_solr'

set :filter, :roles => %{main replication}

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
    on roles(:replication) do
      within release_path do
        execute "pwd"
        directories = []
        Dir.chdir("solr_configs/") do
          directories = Dir.glob('*').select { |f| File.directory? f }
        end
        directories.each {|e| execute "mv #{release_path}/solr_configs/#{e}/conf/solrconfig_replication.xml #{release_path}/solr_configs/#{e}/conf/solrconfig.xml"}  
      end
    end
    on roles(:all), wait: 5 do
      cores = capture "curl 'http://localhost:8983/solr/admin/cores?action=STATUS&wt=json'"
      JSON.parse(cores)['status'].keys.each do |core|
        execute "curl 'http://localhost:8983/solr/admin/cores?action=RELOAD&core=#{core}'"
      end
    end
  end
end
