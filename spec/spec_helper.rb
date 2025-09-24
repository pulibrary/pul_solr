require 'rsolr'
require 'rspec-solr'
require 'faraday'
require 'pry'
require 'webmock/rspec'
require 'byebug'
require_relative '../lando_env'
require_relative '../lib/pul_solr'
$LOAD_PATH.unshift(File.dirname(__FILE__))

RSpec.configure do |config|
  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
end

# The shared context had to be duplicated because using a let to store
# the solr version symbol when getting the port isn't allowed in
# a before(:all) or after(:all) context and the solr method below
# is used in those contexts

# Use this (by calling #include_context) as you would a ruby Module,
# to mixin these methods into an rspec context. This allows contexts
# to access different solr instances and cores.
RSpec.shared_context 'solr8' do

  WebMock.disable_net_connect!(allow_localhost: true)
  # default to the catalog test configuration
  def solr(host: PulSolr.solr_connection[:test][:host],
           core: "solr/blacklight-core",
           dtype: "edismax",
           suffix: "&defType=edismax",
           port: PulSolr.solr_connection[:test][:catalog_solr8][:port])
    unless @solr
      @solr = RSolr.connect :url => "http://#{host}:#{port}/#{core}", :timeout => 9999999
      puts "Solr URL: #{@solr.uri}"
    end
    @solr
  end

  # send a GET request to the default Solr request handler with the indicated Solr parameters
  # @param solr_params [Hash] the key/value pairs to be sent to Solr as HTTP parameters, in addition to
  #  those to get only id fields and no facets in the response
  # @return [RSpecSolr::SolrResponseHash] object for rspec-solr testing the Solr response
  def solr_resp_doc_ids_only(solr_params, request_handler='select')
    solr_response(solr_params.merge(doc_ids_only), request_handler)
  end

  # use these Solr HTTP params to reduce the size of the Solr responses
  # response documents will only have id fields, and there will be no facets in the response
  # @return [Hash] Solr HTTP params to reduce the size of the Solr responses
  def doc_ids_only
    {'fl'=>'id', 'facet'=>'false'}
  end

  # delete all Solr documents
  def delete_all
    solr.delete_by_query('*:*')
    solr.commit
  end

  # gets solr doc from bibdata
  def add_doc(id)
    doc = JSON.parse(File.read(File.expand_path("../fixtures/#{id}.json", __FILE__)))
    solr.add(doc)
    solr.commit
  end

  private

    # send a GET request to the indicated Solr request handler with the indicated Solr parameters
    # @param solr_params [Hash] the key/value pairs to be sent to Solr as HTTP parameters
    # @param req_handler [String] the pathname of the desired Solr request handler (defaults to 'select')
    # @return [RSpecSolr::SolrResponseHash] object for rspec-solr testing the Solr response
    def solr_response(solr_params, req_handler='select')
      response = solr.send_and_receive(req_handler, {:method => :get, :params => solr_params})
      RSpecSolr::SolrResponseHash.new(response)
    end
end

# Use this (by calling #include_context) as you would a ruby Module,
# to mixin these methods into an rspec context. This allows contexts
# to access different solr instances and cores.
RSpec.shared_context 'solr9' do

  WebMock.disable_net_connect!(allow_localhost: true)
  # default to the catalog test configuration
  def solr(host: PulSolr.solr_connection[:test][:host],
           core: "solr/blacklight-core",
           dtype: "edismax",
           suffix: "&defType=edismax",
           port: PulSolr.solr_connection[:test][:catalog_solr9][:port])
    unless @solr
      @solr = RSolr.connect :url => "http://#{host}:#{port}/#{core}", :timeout => 9999999
      puts "Solr URL: #{@solr.uri}"
    end
    @solr
  end

  # send a GET request to the default Solr request handler with the indicated Solr parameters
  # @param solr_params [Hash] the key/value pairs to be sent to Solr as HTTP parameters, in addition to
  #  those to get only id fields and no facets in the response
  # @return [RSpecSolr::SolrResponseHash] object for rspec-solr testing the Solr response
  def solr_resp_doc_ids_only(solr_params, request_handler='select')
    solr_response(solr_params.merge(doc_ids_only), request_handler)
  end

  # use these Solr HTTP params to reduce the size of the Solr responses
  # response documents will only have id fields, and there will be no facets in the response
  # @return [Hash] Solr HTTP params to reduce the size of the Solr responses
  def doc_ids_only
    {'fl'=>'id', 'facet'=>'false'}
  end

  # delete all Solr documents
  def delete_all
    solr.delete_by_query('*:*')
    solr.commit
  end

  # gets solr doc from bibdata
  def add_doc(id)
    doc = JSON.parse(File.read(File.expand_path("../fixtures/#{id}.json", __FILE__)))
    solr.add(doc)
    solr.commit
  end

  private

    # send a GET request to the indicated Solr request handler with the indicated Solr parameters
    # @param solr_params [Hash] the key/value pairs to be sent to Solr as HTTP parameters
    # @param req_handler [String] the pathname of the desired Solr request handler (defaults to 'select')
    # @return [RSpecSolr::SolrResponseHash] object for rspec-solr testing the Solr response
    def solr_response(solr_params, req_handler='select')
      response = solr.send_and_receive(req_handler, {:method => :get, :params => solr_params})
      RSpecSolr::SolrResponseHash.new(response)
    end
end
