require 'date'
require 'fileutils'
require 'logger'
require_relative '../../lib/pul_solr'

namespace :pul_solr do
  namespace :list do
    desc "list collections configuration for given deploy target"
    task :collections do
      target = ENV["TARGET"]
      abort "usage: rake pul_solr:list:collections TARGET=solr8-production" unless target
      collections = PulSolr.collections[config_target(target)]
      collections.each { |collection| puts collection }
    end
  end

  desc "backup all collections on solrcloud server"
  task "backup" do
    target = ENV["SOLR_ENV"]
    host = ENV["HOST"]
    abort "usage: rake pul_solr:backup HOST=solr8 SOLR_ENV=[production|staging]" unless (allowed_targets.include?(target) && allowed_hosts.include?(host))
    collections = PulSolr.collections["#{host}_#{target}"]

    logger = Logger.new("/tmp/solr_backup.log", "monthly")
    backup_manager = PulSolr::BackupManager.new(host: host, solr_env: target, logger: logger)
    backup_manager.cleanup_old_backups
    backup_manager.backup(collections: collections)
  end
end

def config_target(target)
 target.gsub("-", "_").to_sym
end

def allowed_targets
  ["production", "staging"]
end

def allowed_hosts
  ["solr8"]
end
