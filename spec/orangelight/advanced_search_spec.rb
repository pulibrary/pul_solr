# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.shared_examples 'shared subject keyword search' do

  before do
    delete_all
    add_doc('212556')
    add_doc('454035')
    add_doc('1225885')
    solr.commit
  end

  describe 'advanced search dsl query' do
    let(:response) do
      RSpecSolr::SolrResponseHash.new(solr.send_and_receive('advanced', params))['response']
    end
    let(:docs) { response['docs'] }
    let(:params) do
      { data:
        '{"params":'\
          '{"qt":null,"spellcheck.dictionary":"title",'\
           '"qf":"${title_qf}","pf":"${title_pf}",'\
           '"facet":true,'\
           '"f.access_facet.facet.sort":"index","f.location.facet.sort":"index",'\
           '"f.location.facet.mincount":1,"f.location.facet.limit":21,'\
           '"facet.pivot":["lc_1letter_facet,lc_rest_facet"],"f.sudoc_facet.facet.sort":"index",'\
           '"f.sudoc_facet.facet.limit":11,"rows":20,"sort":"score desc, pub_date_start_sort desc, title_sort asc",'\
           '"stats":"true","stats.field":["pub_date_start_sort"],"q":null},'\
          '"query":{"bool":{"must":['\
            '{"edismax":{"spellcheck.dictionary":"title","qf":"${title_qf}","pf":"${title_pf}","query":"Theory of the avant-garde"}}]}}}',
        method: :post, headers: { 'Content-Type' => 'application/json' } }
    end
    it 'returns one document that matches the boolean query' do
      expect(response['docs'].length).to eq(1)
      expect(response['docs'].first['id']).to eq('212556')
    end
  end
end

RSpec.describe 'subject keyword search' do
  context 'with solr8' do
    include_context 'solr8'
    include_examples 'shared subject keyword search'
  end

    context 'with solr9' do
    include_context 'solr9'
    include_examples 'shared subject keyword search'
  end
end
