require 'net/http'
require 'logger'
require 'json'

module PulSolr
  class BackupManager
    attr_reader :base_dir, :host, :solr_env, :base_url, :logger
    def initialize(base_dir: "/mnt/solr_backup", host:, solr_env:, base_url: "http://localhost:8983", logger:)
      @base_dir = base_dir
      @solr_env = solr_env
      @host = host
      @base_url = base_url
      @logger = logger
    end

    # delete old backup directories
    def cleanup_old_backups
      logger.info "Deleting backups from before #{oldest_backup_date}"
      Dir[File.join(base_dir, host, solr_env, "*")].select { |d| older_than_threshold?(d) }.each do |d|
        FileUtils.rmtree(d)
      end
      logger.info "Backups deleted from before #{oldest_backup_date}"
    end

    def backup_dir
      @backup_dir ||=
        begin
          FileUtils.mkdir_p(destination)
          logger.info("Backup directory is #{destination}")
          destination
        end
    end

    # @param collections [Array<String>]
    def backup
      list_collections.each do |collection|
        request_status = "#{collection}-#{timestamp}"
        logger.info "Begin backing up collection: #{collection} with request status #{request_status}"
        url_path = "/solr/admin/collections?action=BACKUP&name=#{collection}-#{today_str}.bk&collection=#{collection}&location=#{backup_dir}&async=#{request_status}"
        uri = URI.parse("#{base_url}#{url_path}")
        response = Net::HTTP.get_response(uri)
        logger.info("Finished backing up collection: #{collection} with response code: #{response.code} and message: #{response.message}")
      end
    end

    def list_collections
      url_path = "/api/collections"
      uri = URI.parse("#{base_url}#{url_path}")
      response = Net::HTTP.get_response(uri)
      JSON.parse(response.body)["collections"]
    end

    private

      def destination
        File.absolute_path(File.join(base_dir, host, solr_env, today_str))
      end

      def today_str
        Date.today.strftime("%Y%m%d")
      end

      def timestamp
        Time.now.strftime("%Y%m%d%H%M")
      end

      # Should we delete the directory?
      def older_than_threshold?(directory)
        File.mtime(directory).to_date < (oldest_backup_date)
      end

      # three weeks ago
      def oldest_backup_date
        Date.today - 21
      end
  end
end
