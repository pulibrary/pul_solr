# frozen_string_literal: true

require 'spec_helper'
require 'rspec/expectations'

RSpec::Matchers.define :contain_only_hexadecimal_characters do
  match do |string|
    !string[/\H/]
  end
end

RSpec.shared_examples 'shared hash id field solrconfig update handler' do

  before(:all) do
    delete_all
  end
  describe 'all documents get a hashed_id_s field after indexing' do
    before(:all) do
      solr.add({ id: 1, title_display: 'Any solr document' })
      solr.commit
    end
    it 'hashed id field is indexed' do
      expect(solr_resp_doc_ids_only({ 'q': 'hashed_id_ssi:*' })).to include('1')
    end
    it 'creates hexadecimal hashes of the expected length' do
      response = solr_response({ 'q' => 'id:1', 'fl' => 'hashed_id_ssi' })
      hashed_id = response['response']['docs'].first['hashed_id_ssi']
      expect(hashed_id.length).to eq(16)
      expect(hashed_id).to contain_only_hexadecimal_characters
    end
  end
  after(:all) do
    delete_all
  end
end

RSpec.describe 'hash id field solrconfig update handler' do
  context 'with solr8' do
    include_context 'solr8'
    include_examples 'shared hash id field solrconfig update handler'
  end

    context 'with solr9' do
    include_context 'solr9'
    include_examples 'shared hash id field solrconfig update handler'
  end
end
