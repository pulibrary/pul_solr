require 'rsolr'
require 'rspec-solr'
require 'faraday'
$LOAD_PATH.unshift(File.dirname(__FILE__))

RSpec.configure do |config|


  host = "localhost"
  core = "solr/blacklight-core"
  dtype = "edismax"
  suffix = "&defType=edismax"
  prt = 8888


  @@solr = RSolr.connect :url => "http://#{host}:#{prt}/#{core}", :read_timeout => 9999999 
  #solr_config = ENV['TRAVIS'] ? YAML::load_file('config/solr.yml')["test"] : YAML::load_file('config/solr.yml')["dev"]
  #@@solr = RSolr.connect(solr_config)
  puts "Solr URL: #{@@solr.uri}"

end

# send a GET request to the default Solr request handler with the indicated Solr parameters
# @param solr_params [Hash] the key/value pairs to be sent to Solr as HTTP parameters, in addition to 
#  those to get only id fields and no facets in the response
# @return [RSpecSolr::SolrResponseHash] object for rspec-solr testing the Solr response 
def solr_resp_doc_ids_only(solr_params)
  solr_response(solr_params.merge(doc_ids_only))
end

# use these Solr HTTP params to reduce the size of the Solr responses
# response documents will only have id fields, and there will be no facets in the response
# @return [Hash] Solr HTTP params to reduce the size of the Solr responses
def doc_ids_only
  {'fl'=>'id', 'facet'=>'false'}
end

# delete all Solr documents
def delete_all
  @@solr.delete_by_query('*:*')
  @@solr.commit
end

# gets solr doc from bibdata
def add_doc(id)
  doc = JSON.parse(File.read(File.expand_path("../fixtures/#{id}.json", __FILE__)))
  @@solr.add(doc)
  @@solr.commit
end

private

# send a GET request to the indicated Solr request handler with the indicated Solr parameters
# @param solr_params [Hash] the key/value pairs to be sent to Solr as HTTP parameters
# @param req_handler [String] the pathname of the desired Solr request handler (defaults to 'select') 
# @return [RSpecSolr::SolrResponseHash] object for rspec-solr testing the Solr response 
def solr_response(solr_params, req_handler='select')  
  RSpecSolr::SolrResponseHash.new(@@solr.send_and_receive(req_handler, {:method => :get, :params => solr_params}))
end