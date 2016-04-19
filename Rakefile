require 'rspec/core/rake_task'
require 'solr_wrapper'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

solr_download_path = '/tmp'
solr_instance_path = "#{solr_download_path}/solr"
solr_home_path = 'configs'

# Remove this after upgrading to latest solr_wrapper
SolrWrapper.default_instance_options = {
    verbose: true,
    port: '8888',
    version: '5.4.1',
    instance_dir: solr_instance_path,
    download_dir: solr_download_path,
    solr_options: {'s' => solr_home_path}
}

require 'solr_wrapper/rake_task'

namespace :pulsolr do
  desc "Copies Solr-distributed analysis libraries into Solr home directory"
  task :lib do
    FileUtils.cp("#{solr_home_path}/lib/contrib/analysis-extras/lib/CJKFoldingFilter.jar",
                 "#{solr_instance_path}/contrib/analysis-extras/lib")
    FileUtils.cp_r("#{solr_instance_path}/contrib/analysis-extras/lib",
                 "#{solr_home_path}/lib/contrib/analysis-extras")
    FileUtils.cp_r("#{solr_instance_path}/contrib/analysis-extras/lucene-libs",
                 "#{solr_home_path}/lib/contrib/analysis-extras")
  end
end