require_relative 'pul_solr/backup_manager'
require 'yaml'

module PulSolr
  def self.solr_connection
    host = ENV['SOLR_URL'] == "http://solr8:8983/solr" ? "solr:SolrRocks@solr8" : "solr:SolrRocks@solr9"
    port = ENV['SOLR_URL'] == "http://solr8:8983/solr" ? "8983" : "8984"
    @@solr_connection ||= {
      test: {
        host: ENV['CI'] ? host : "localhost",
        catalog: {
          port: ENV['CI'] ? port : ENV['lando_blacklight_test_solr_conn_port'],
          core: "solr/blacklight-core",
        },
        dss: {
          port: ENV['CI'] ? "8983" : ENV['lando_dss_test_solr_conn_port'],
          core: ENV['CI'] ? "solr/dss-core" : "solr/blacklight-core"
        },
        pulmap: {
          port: ENV['CI'] ? "8983" : ENV['lando_pulmap_test_solr_conn_port'],
          core: ENV['CI'] ? "solr/pulmap-core" : "solr/blacklight-core"
        }
      }
    }
  end
end
