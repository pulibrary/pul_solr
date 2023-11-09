# frozen_string_literal: true

require 'spec_helper'
require 'json'

describe 'unified highlighting component' do
  include_context 'solr_helpers'

  let(:highlighted_doc) {'1355809'}

  before do
    delete_all
    add_doc(highlighted_doc)
    add_doc('212556')
    add_doc('454035')
    add_doc('1225885')
    solr.commit
  end

  describe 'highlighting' do
    let(:response) do
      solr_response({q: "Patterns in nature"})
    end
    let(:docs) { response['docs'] }
    
    it 'has a highlighting section' do
      expect(response['highlighting']).to be_truthy
    end
    it 'highlighting includes highlighted doc id with emphasis' do
      expect(response['highlighting']['1355809']['title_display'][0]).to include('<em>')
    end
  end
end