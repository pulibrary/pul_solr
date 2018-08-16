# encoding: utf-8
require 'spec_helper'
require 'json'

describe 'apostrophes are stripped' do
  include_context 'solr_helpers'

  let(:contraction) { "Can't and Won't" }
  let(:cyrillic) { "Bratʹi︠a︡ Karamazovy" }
  let(:french) { "l'opéra-comique français"}
  let(:response) { solr_resp_doc_ids_only(params)['response'] }
  let(:docs) { response['docs'] }

  before do
    solr.add({ id: 1, title_display: [contraction] })
    solr.commit
  end

  describe 'in all_fields search (text field)' do
    let(:params) do
      { 'q' => "can't" }
    end

    it 'matches when apostrophe included in query for contraction' do
      expect(docs).to eq([{ "id" => "1" }])
    end

    context 'when apostrophe excluded in query for contraction' do
      let(:params) do
        { 'q' => "cant" }
      end

      it 'matches' do
        expect(docs).to eq([{ "id" => "1" }])
      end
    end

    context 'for Romanized Cyrillic' do
      before do
        solr.add({ id: 1, title_display: [cyrillic] })
        solr.commit
      end

      context 'when apostrophe included in query for Romanized Cyrillic' do
        let(:params) do
          { 'q' => "brat'ia" }
        end
        let(:response) { solr_resp_doc_ids_only(params)['response'] }
        let(:docs) { response['docs'] }

        it 'matches' do
          expect(docs).to eq([{ "id" => "1" }])
        end
      end

      context 'when apostrophe excluded in query for Romanized Cyrillic' do
        let(:params) do
          { 'q' => "Bratia" }
        end
        let(:response) { solr_resp_doc_ids_only(params)['response'] }
        let(:docs) { response['docs'] }

        it 'matches' do
          expect(docs).to eq([{ "id" => "1" }])
        end
      end
    end

    context 'for French searches with articles' do
      before do
        solr.add({ id: 1, title_display: [french] })
        solr.commit
      end

      context 'when apostrophe included in query, no whitespace after article' do
        let(:params) do
          { 'q' => "l'opera" }
        end
        let(:response) { solr_resp_doc_ids_only(params)['response'] }
        let(:docs) { response['docs'] }

        it 'matches' do
          expect(docs).to eq([{ "id" => "1" }])
        end
      end

      context 'when apostrophe excluded in query, no whitespace after article' do
        let(:params) do
          { 'q' => "lopera" }
        end
        let(:response) { solr_resp_doc_ids_only(params)['response'] }
        let(:docs) { response['docs'] }

        it 'matches' do
          expect(docs).to eq([{ "id" => "1" }])
        end
      end

      context 'when apostrophe included in query, whitespace after article' do
        let(:params) do
          { 'q' => "l' opera" }
        end
        let(:response) { solr_resp_doc_ids_only(params)['response'] }
        let(:docs) { response['docs'] }

        it 'matches' do
          expect(docs).to eq([{ "id" => "1" }])
        end
      end
    end
  end

  describe 'in left_anchor search' do
    let(:params) do
      { 'q' => "{!qf=$left_anchor_qf pf=$left_anchor_pf}can’t*" }
    end
    let(:response) { solr_resp_doc_ids_only(params)['response'] }
    let(:docs) { response['docs'] }

    it 'matches when apostrophe included in query for contraction' do
      expect(docs).to eq([{ "id" => "1" }])
    end

    context 'when apostrophe excluded in query for contraction' do
      let(:params) do
        { 'q' => '{!qf=$left_anchor_qf pf=$left_anchor_pf}cant*' }
      end

      it 'matches' do
        expect(docs).to eq([{ "id" => "1" }])
      end
    end
  end

  after do
    delete_all
  end
end
