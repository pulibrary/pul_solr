require 'date'
require 'fileutils'
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

  namespace :solr8 do
    desc "backup all collections on production solr8 server"
    task "backup" do
      target = ENV["SOLR_ENV"]
      abort "usage: rake pul_solr:solr8:backup SOLR_ENV=[production|staging]" unless allowed_targets.include? target
      collections = PulSolr.collections["solr8_#{target}"]

      backup_manager = PulSolr::BackupManager.new(solr_env: target)
      puts "Deleting old backups"
      backup_manager.cleanup_old_backups
      puts "Backing up collections: #{collections}"
      backup_manager.backup(collections: collections)
    end
  end
end

def config_target(target)
 target.gsub("-", "_").to_sym
end

def allowed_targets
  ["production", "staging"]
end
