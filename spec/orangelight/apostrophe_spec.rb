require 'spec_helper'
require 'json'

describe 'apostrophes are stripped' do
  include_context 'solr_helpers'

  let(:contraction) { 'Can\'t and Won\'t' }
  let(:cyrillic) { 'Bratʹi︠a︡ Karamazovy' }
  let(:response) { solr_resp_doc_ids_only(params) }

  before do
    delete_all
    solr.add({ id: 1, title_a_index: [contraction, cyrillic] })
    solr.commit
  end

  describe 'in all_fields search (text field)' do
    let(:params) do
      { 'q' => "can't" }
    end

    it 'matches when apostrophe included in query for contraction' do
      expect(response).to include('1')
    end
    context 'when apostrophe excluded in query for contraction' do
      let(:params) do
        { 'q' => "cant" }
      end

      it 'matches' do
        expect(response).to include('1')
      end
    end

    context 'when apostrophe included in query for Romanized Cyrillic' do
      let(:params) do
        { 'q' => "brat'ia" }
      end

      it 'matches' do
        expect(response).to include('1')
      end
    end

    context 'when apostrophe excluded in query for Romanized Cyrillic' do
      let(:params) do
        { 'q' => "bratia" }
      end

      it 'matches' do
        expect(response).to include('1')
      end
    end
  end

  describe 'in left_anchor search' do
    let(:params) do
      { 'q' => "{!qf=$left_anchor_qf pf=$left_anchor_pf}can’t" }
    end

    it 'matches when apostrophe included in query for contraction' do
      expect(response).to include('1')
    end

    context 'when apostrophe excluded in query for contraction' do
      let(:params) do
        { 'q' => '{!qf=$left_anchor_qf pf=$left_anchor_pf}cant' }
      end

      it 'matches' do
        expect(response).to include('1')
      end
    end
  end

  after do
    delete_all
  end
end
