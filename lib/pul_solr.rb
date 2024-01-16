require_relative 'pul_solr/backup_manager'

module PulSolr
  def self.collections
    @@collections ||= YAML.safe_load(File.read(File.join("config", "collections.yml")))
  end

  def self.solr_connection
    @@solr_connection ||= {
      test: {
        host: ENV['CI'] ? "solr:SolrRocks@localhost" : "localhost",
        catalog: {
          port: ENV['CI'] ? "8983" : ENV['lando_blacklight_test_solr_conn_port'],
          core: "solr/blacklight-core",
        },
        pulmap: {
          port: ENV['CI'] ? "8983" : ENV['lando_pulmap_test_solr_conn_port'],
          core: ENV['CI'] ? "solr/pulmap-core" : "solr/blacklight-core"
        }
      }
    }
  end
end
