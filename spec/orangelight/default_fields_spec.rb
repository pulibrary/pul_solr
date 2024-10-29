# encoding: utf-8
require 'spec_helper'

describe 'default fields' do
  include_context 'solr_helpers'

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
