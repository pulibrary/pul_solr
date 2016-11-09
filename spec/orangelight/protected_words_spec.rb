require 'spec_helper'
require 'json'

describe 'protected words' do
  include_context 'solr_helpers'

  before(:all) do
    delete_all
  end
  context 'when performing a keyword search using a protected word' do
    not_stemmed = '2393109'
    stemmed = '1261826'
    before(:all) do
      add_doc(not_stemmed)
      add_doc(stemmed)
    end
    it 'does not stem the word' do
      expect(solr_resp_doc_ids_only({ 'q' => 'constanter' })).to include(not_stemmed)
      expect(solr_resp_doc_ids_only({ 'q' => 'constanter' })).not_to include(stemmed)
    end
  end
  after(:all) do
    delete_all
  end
end
