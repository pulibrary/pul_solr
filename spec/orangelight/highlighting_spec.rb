# frozen_string_literal: true

require 'spec_helper'
require 'json'

describe 'unified highlighting component' do
  include_context 'solr_helpers'

  before do
    delete_all
    add_doc('1355809')
    add_doc('212556')
    add_doc('454035')
    add_doc('1225885')
    add_doc('99125315781206421')
    add_doc('99129071662406421')
    solr.commit
  end

  describe 'highlighting' do
    
    let(:docs) { response['docs'] }

    context 'highlights title' do
      let(:response) do
        solr_response({q: "Patterns in nature"})
      end
      it 'highlighting includes title_display field with emphasis' do
        expect(response['highlighting']['1355809']['title_display'][0]).to include('<em>')
      end
    end
    context 'highlights author' do
      let(:response) do
        solr_response({q: "Stevens"})
      end
      it 'highlighting includes author_display field with emphasis' do
        expect(response['highlighting']['1355809']['author_display'][0]).to include('<em>')
      end
    end
    context 'highlights subject' do
      let(:response) do
        solr_response({q: "morphology"})
      end
      it 'highlighting includes subject_display field with emphasis' do
        expect(response['highlighting']['1355809']['subject_display'][0]).to include('<em>')
      end
    end
    context 'highlights notes_display' do
      let(:response) do
        solr_response({q: "Atlantic"})
      end
      it 'highlighting includes notes_display field with emphasis' do
        expect(response['highlighting']['1355809']['notes_display'][0]).to include('<em>')
      end
    end
    context 'highlights any matching term for an hl.fl field' do
      let(:response) do
        solr_response( { q: "black teenagers" })
      end
      it "higlighting includes active highlighted fields with any matching query term" do
        expect(response['highlighting']['99125315781206421']['title_display']).to eq(["Birth Cohort and the <em>Black</em>-White Achievement Gap: The Roles of Access and Health Soon After Birth / Kenneth Y. "])
      end
    end
  end
end
