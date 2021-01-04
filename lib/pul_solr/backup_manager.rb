require 'net/http'

module PulSolr
  class BackupManager
    attr_reader :base_dir, :solr_env, :base_url
    def initialize(base_dir: "/mnt/solr_backup", solr_env:, base_url: "http://localhost:8983/solr")
      @base_dir = base_dir
      @solr_env = solr_env
      @base_url = base_url
    end

    # delete old backup directories
    def cleanup_old_backups
      Dir[File.join(base_dir, solr_env, "*")].select { |d| three_weeks_old?(d) }.each do |d|
        FileUtils.rmtree(d)
      end
    end

    def backup_dir
      @backup_dir ||=
        begin
          FileUtils.mkdir_p(destination)
          destination
        end
    end

    # @param collections [Array<String>]
    def backup(collections:)
      collections.each do |collection|
        url_path = "/admin/collections?action=BACKUP&name=#{collection}-#{today_str}.bk&collection=#{collection}&location=#{backup_dir}&async=#{collection}#{timestamp}"
        uri = URI.parse("#{base_url}#{url_path}")
        response = Net::HTTP.get_response(uri)
      end
    end

    private

      def destination
        File.absolute_path(File.join(base_dir, solr_env, today_str))
      end

      def today_str
        Date.today.strftime("%Y%m%d")
      end

      def timestamp
        Time.now.strftime("%Y%m%d%H%M%S")
      end

      # Should we delete the directory?
      def three_weeks_old?(directory)
        File.mtime(directory).to_date < (Date.today - 21)
      end
  end
end
