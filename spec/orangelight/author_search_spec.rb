require 'spec_helper'
require 'json'

describe 'author keyword search' do
  def author_query_string q
    "{!qf=$author_qf pf=$author_pf}#{q}"
  end
  before(:all) do
    delete_all
  end
  describe 'diacritics' do
    diacritic_name = '7419275'
    before(:all) do
      add_doc(diacritic_name)
    end
    it 'retrieves book when diacritics included' do
      expect(solr_resp_doc_ids_only({ 'q' => author_query_string('Moiseĭ') })).to include(diacritic_name)
    end
    it 'retrieves book when diacritics excluded' do
      expect(solr_resp_doc_ids_only({ 'q' => author_query_string('Moisei') })).to include(diacritic_name)
    end
  end
  describe 'author 1xx field' do
    author = '484612'
    related_name = '5188770'
    before(:all) do
      add_doc(author)
      add_doc(related_name)
    end
    it 'author 1xx match returned before 7xx match' do
      expect(solr_resp_doc_ids_only({ 'q' => author_query_string('Fellbaum') })).to include(author).before(related_name)
    end
  end
  after(:all) do
    delete_all
  end
end