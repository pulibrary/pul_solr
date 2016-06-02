require 'spec_helper'
require 'json'

describe 'text field configuration' do
  before(:all) do
    delete_all
  end
  describe 'apostrophes are stripped' do
    contraction = "Can't and Won't"
    cyrillic = 'Bratʹi︠a︡ Karamazovy'
    before(:all) do
      @@solr.add({ id: 1, title_t: [contraction, cyrillic] })
      @@solr.commit
    end
    it 'matches when apostrophe included in query for contraction' do
      expect(solr_resp_doc_ids_only({ 'q' => "can't" })).to include('1')
    end
    it 'matches when apostrophe excluded in query for contraction' do
      expect(solr_resp_doc_ids_only({ 'q' => 'cant' })).to include('1')
    end
    it 'matches when apostrophe included in query for Romanized Cyrillic' do
      expect(solr_resp_doc_ids_only({ 'q' => "brat'ia" })).to include('1')
    end
    it 'matches when apostrophe excluded in query for Romanized Cyrillic' do
      expect(solr_resp_doc_ids_only({ 'q' => 'bratia' })).to include('1')
    end
  end
  after(:all) do
    delete_all
  end
end
