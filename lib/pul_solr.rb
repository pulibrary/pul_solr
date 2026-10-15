require_relative 'pul_solr/backup_manager'
require 'yaml'

module PulSolr
  def self.solr_connection
    @@solr_connection ||= {
      test: {
        host: ENV['CI'] ? "solr:SolrRocks@localhost" : "localhost",
        catalog_solr9: {
          port: ENV['CI'] ? '8984' : ENV['SOLR_PORT'] || ENV['lando_blacklight_test_solr_9_conn_port'] || '8983',
          core: "solr/blacklight-core",
        },
        dss: {
          port: ENV['CI'] ? "8984" : ENV['SOLR_PORT'] || ENV['lando_dss_test_solr_conn_port'] || '8983',
          core: "solr/dss-core"
        },
        pulmap: {
          port: ENV['CI'] ? "8983" : ENV['SOLR_PORT'] ||  ENV['lando_pulmap_test_solr_conn_port'] || '8983',
          core: "solr/pulmap-core"
        }
      }
    }
  end
end
