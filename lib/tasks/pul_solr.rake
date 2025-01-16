require 'date'
require 'fileutils'
require 'logger'
require_relative '../../lib/pul_solr'

namespace :pul_solr do
  desc "backup all collections on solrcloud server"
  task "backup" do
    target = ENV["SOLR_ENV"]
    host = ENV["HOST"]
    abort "usage: rake pul_solr:backup HOST=solr8 SOLR_ENV=[production|staging]" unless (allowed_targets.include?(target) && allowed_hosts.include?(host))
    logger = Logger.new("/tmp/solr_backup.log", "monthly")
    backup_manager = PulSolr::BackupManager.new(host: host, solr_env: target, logger: logger)
    backup_manager.backup
  end

  desc "clean up old collections on solrcloud server"
  task "cleanup" do
    target = ENV["SOLR_ENV"]
    host = ENV["HOST"]
    abort "usage: rake pul_solr:cleanup HOST=solr8 SOLR_ENV=[production|staging]" unless (allowed_targets.include?(target) && allowed_hosts.include?(host))
    logger = Logger.new("/tmp/solr_backup.log", "monthly")
    backup_manager = PulSolr::BackupManager.new(host: host, solr_env: target, logger: logger)
    backup_manager.cleanup_old_backups
  end

  desc "copies files from another project that has been checked out locally"
  task :sync do
    from_dir = ENV["FROM_DIR"]
    configset = ENV["CONFIGSET"]
    abort "usage: rake pul_solr:sync FROM_DIR=../dpul-collections CONFIGSET=dpulc-staging" unless from_dir && configset

    FileUtils.cp_r(File.join(from_dir, "solr", "conf"), File.join("solr_configs", configset))
  end
end

def config_target(target)
 target.gsub("-", "_").to_sym
end

def allowed_targets
  ["production", "staging"]
end

def allowed_hosts
  ["solr8", "solr9"]
end
