# encoding: utf-8
require 'spec_helper'
require 'json'
require 'byebug'

describe 'apostrophes are stripped' do
  include_context 'solr_helpers'

  let(:contraction) { "Can't and Won't" }
  let(:cyrillic_name) { "Arsenʹev, Alekseĭ Aleksandrovich" }
  let(:cyrillic) { "Bratʹi︠a︡ Karamazovy" }
  let(:french) { "l'opéra-comique français"}
  let(:response) { solr_resp_doc_ids_only(params)['response'] }
  let(:docs) { response['docs'] }
  let(:solr_doc) { { id: 1, title_display: [contraction] } }

  around do |example|
    solr.add(solr_doc)
    solr.commit
    example.run
    delete_all
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
      let(:solr_doc) { { id: 1, title_display: [cyrillic] } }

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

      context 'when OCLC apostrophe included in query for Romanized Cyrillic' do
        let(:params) do
          { 'q' => "bratʹia" }
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
      let(:solr_doc) { { id: 1, title_display: [french] } }

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
      { qf: "${left_anchor_qf}", pf: "${left_anchor_pf}", q: "can’t*" }
    end
    let(:response) { solr_resp_doc_ids_only(params)['response'] }
    let(:docs) { response['docs'] }

    it 'matches when apostrophe included in query for contraction' do
      expect(docs).to eq([{ "id" => "1" }])
    end

    context 'when apostrophe excluded in query for contraction' do
      let(:params) do
        { qf: "${left_anchor_qf}", pf: "${left_anchor_pf}", q: "cant*" }
      end

      it 'matches' do
        expect(docs).to eq([{ "id" => "1" }])
      end
    end
  end

  describe 'in author search' do
    context 'for Romanized Cyrillic name' do
      let(:response) { solr_resp_doc_ids_only(params)['response'] }
      let(:docs) { response['docs'] }
      let(:solr_doc) { { id: 1, author_s: [cyrillic_name] } }

      context 'when apostrophe is included in query' do
        let(:params) do
          { qf: "${author_qf}", pf: "${author_pf}", 'q' => "arsen'ev" }
        end
        it 'matches' do
          expect(docs).to eq([{ "id" => "1" }])
        end
      end
      context 'when OCLC special character is included in query' do
        let(:params) do
          { qf: "${author_qf}", pf: "${author_pf}", 'q' => "arsenʹev" }
        end
        it 'matches' do
          expect(docs).to eq([{ "id" => "1" }])
        end
      end
      context 'when apostrophe is not included in query' do
        let(:params) do
          { qf: "${author_qf}", pf: "${author_pf}", 'q' => "arsenev" }
        end
        it 'matches' do
          expect(docs).to eq([{ "id" => "1" }])
        end
      end
    end
  end
end
