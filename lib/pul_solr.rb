require_relative 'pul_solr/backup_manager'

module PulSolr
  def self.collections
    @@collections ||= YAML.safe_load(File.read(File.join("config", "collections.yml")))
  end
end
