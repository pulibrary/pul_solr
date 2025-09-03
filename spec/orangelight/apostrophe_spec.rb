# encoding: utf-8
require 'spec_helper'
require 'json'

RSpec.shared_examples 'shared apostrophes are stripped' do

  let(:contraction) { "Can't and Won't" }
  let(:cyrillic_name) { "Arsenʹev, Alekseĭ Aleksandrovich" }
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

      before do
        solr.add({ id: 1, author_s: [cyrillic_name] })
        solr.commit
      end

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

  after do
    delete_all
  end
end

RSpec.describe 'apostrophes are stripped' do
  context 'with solr8' do
    include_context 'solr8'
    include_examples 'shared apostrophes are stripped'
  end

    context 'with solr9' do
    include_context 'solr9'
    include_examples 'shared apostrophes are stripped'
  end
end
