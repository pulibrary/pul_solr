require 'spec_helper'
require 'json'

describe 'apostrophes are stripped' do
  contraction = "Can't and Won't"
  cyrillic = 'Bratʹi︠a︡ Karamazovy'
  before(:all) do
    delete_all
    @@solr.add({ id: 1, title_a_index: [contraction, cyrillic] })
    @@solr.commit
  end

  describe 'in all_fields search (text field)' do
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

  describe 'in left_anchor search' do
    it 'matches when apostrophe included in query for contraction' do
      expect(solr_resp_doc_ids_only({ 'q' => "{!qf=$left_anchor_qf pf=$left_anchor_pf}can’t" })).to include('1')
    end
    it 'matches when apostrophe excluded in query for contraction' do
      expect(solr_resp_doc_ids_only({ 'q' => '{!qf=$left_anchor_qf pf=$left_anchor_pf}cant' })).to include('1')
    end
  end
  after(:all) do
    delete_all
  end
end
