require 'spec_helper'
require 'json'

RSpec.shared_examples 'shared protected words' do

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

RSpec.describe 'protected words' do
  context 'with solr8' do
    include_context 'solr8'
    include_examples 'shared protected words'
  end

    context 'with solr9' do
    include_context 'solr9'
    include_examples 'shared protected words'
  end
end
