# encoding: utf-8
require 'spec_helper'

RSpec.shared_examples 'shared default fields' do

  before do
    delete_all
    add_doc('212556')
    solr.commit
  end
  it 'contains call_number_display field' do
    docs = solr.get('select', :params => {q: 'id:212556'})['response']['docs']
    expect(docs.first['call_number_display']).to contain_exactly 'BH301.A94 B8313 1984'
  end

  after do
    delete_all
    solr.commit
  end
end

RSpec.describe 'default fields' do
  context 'with solr8' do
    include_context 'solr8'
    include_examples 'shared default fields'
  end

    context 'with solr9' do
    include_context 'solr9'
    include_examples 'shared default fields'
  end
end
