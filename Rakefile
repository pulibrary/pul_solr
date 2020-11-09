require 'rspec/core/rake_task'
require 'solr_wrapper'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

solr_download_path = '/tmp'
solr_instance_path = "#{solr_download_path}/solr"
solr_home_path = 'solr_configs'

SolrWrapper.default_instance_options = {
    verbose: true,
    port: '8888',
    version: '8.4.1',
    instance_dir: solr_instance_path,
    download_dir: solr_download_path,
    solr_options: {'s' => solr_home_path}
}

require 'solr_wrapper/rake_task'
Dir[File.join(__dir__, 'lib', 'tasks', '*.rake')].each {|file| import file }
