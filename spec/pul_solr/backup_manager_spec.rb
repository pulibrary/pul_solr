require 'spec_helper'
require_relative '../../lib/pul_solr'
require 'date'
require 'fileutils'

describe PulSolr::BackupManager do
  let(:base_dir) { "spec/tmp" }
  let(:host) { "solr8" }
  let(:solr_env) { "test" }
  let(:backup_manager) { PulSolr::BackupManager.new(base_dir: base_dir, host: host, solr_env: solr_env, logger: Logger.new(nil)) }
  let(:today_str) { Date.today.strftime("%Y%m%d") }

  before do
    FileUtils.rmtree(base_dir)
  end

  describe "#cleanup_old_backups" do
    it "clean up backup directories older than 3 weeks ago" do
      today_dir = File.join(base_dir, host, solr_env, today_str)
      three_weeks_ago = Date.today - 22
      three_weeks_ago_dir = File.join(base_dir, host, solr_env, three_weeks_ago.strftime("%Y%m%d"))
      FileUtils.mkdir_p(today_dir)
      FileUtils.mkdir_p(three_weeks_ago_dir)
      FileUtils.touch(
        File.join(three_weeks_ago_dir, "some_collection.solr"),
        mtime: three_weeks_ago.to_time
      )
      FileUtils.touch(
        three_weeks_ago_dir,
        mtime: three_weeks_ago.to_time
      )
      expect(Dir.exist?(three_weeks_ago_dir)).to eq true

      backup_manager.cleanup_old_backups
      expect(Dir.exist?(today_dir)).to eq true
      expect(Dir.exist?(three_weeks_ago_dir)).to eq false
    end
  end

  describe "#backup_dir" do
    it "creates and returns a backup directory for today's backup" do
      FileUtils.mkdir_p(base_dir)
      expect(backup_manager.backup_dir).to start_with "/"
      expect(backup_manager.backup_dir).to end_with "/#{base_dir}/#{host}/#{solr_env}/#{today_str}"
    end
  end

  describe "#backup" do
    it "issues commands to solr via the collections api" do
      url = "http://localhost:8983/solr/admin/collections"
      test_params = {
        "action" => "BACKUP",
        "collection" => "test-staging",
        "location" => File.join(File.absolute_path(base_dir), host, solr_env, today_str),
        "name" => "test-staging-#{today_str}.bk"
      }
      staging_params = {
        "action" => "BACKUP",
        "collection" => "test",
        "location" => File.join(File.absolute_path(base_dir), host, solr_env, today_str),
        "name" => "test-#{today_str}.bk"
      }
      stub_request(:get, url)
        .with(:query => hash_including(test_params))
        .to_return(status: 200, body: "", headers: {})
      stub_request(:get, url)
        .with(:query => hash_including(staging_params))
        .to_return(status: 200, body: "", headers: {})
      FileUtils.mkdir_p(base_dir)
      collections = ["test", "test-staging"]

      backup_manager.backup(collections: collections)
      expect(a_request(:get, url).with(query: hash_including(test_params))).to have_been_made
      expect(a_request(:get, url).with(query: hash_including(staging_params))).to have_been_made
    end
  end
  describe 'logging' do
    let(:logger) { Logger.new(nil) }
    let(:backup_manager) { PulSolr::BackupManager.new(base_dir: base_dir, host: host, 
                                                      solr_env: solr_env, logger:) }
    it 'logs before and after cleaning up backups' do
      allow(logger).to receive(:info)
      backup_manager.cleanup_old_backups
      expect(logger).to have_received(:info).twice
      expect(logger).to have_received(:info).with(/Deleting backups from before/)
      expect(logger).to have_received(:info).with(/Backups deleted from before/)
    end

    it "logs the file it's backing up to" do
      allow(logger).to receive(:info)
      backup_manager.backup_dir
      expect(logger).to have_received(:info).with(/Backup directory is/)
    end

    it 'logs before and after backing up a collection' do
      url = "http://localhost:8983/solr/admin/collections"
      test_params = {
        "action" => "BACKUP",
        "collection" => "test-staging",
        "location" => File.join(File.absolute_path(base_dir), host, solr_env, today_str),
        "name" => "test-staging-#{today_str}.bk"
      }
      staging_params = {
        "action" => "BACKUP",
        "collection" => "test",
        "location" => File.join(File.absolute_path(base_dir), host, solr_env, today_str),
        "name" => "test-#{today_str}.bk"
      }
      stub_request(:get, url)
        .with(:query => hash_including(test_params))
        .to_return(status: 200, body: "", headers: {})
      stub_request(:get, url)
        .with(:query => hash_including(staging_params))
        .to_return(status: 200, body: "", headers: {})
      FileUtils.mkdir_p(base_dir)
      collections = ["test", "test-staging"]

      allow(logger).to receive(:info)
      backup_manager.backup(collections: collections)
      expect(logger).to have_received(:info).with(/Backup directory is/)
      expect(logger).to have_received(:info).with(/Begin backing up collection: test with request status/)
      expect(logger).to have_received(:info).with(/Begin backing up collection: test-staging with request status/)
      expect(logger).to have_received(:info).with(/Finished backing up collection: test with response code: 200 and message: /)
      expect(logger).to have_received(:info).with(/Finished backing up collection: test-staging with response code: 200 and message: /)
    end
  end
end
