require 'spec_helper'
require 'json'

RSpec.shared_examples 'shared author keyword search' do

  def author_query_params q
    { qf: "${author_qf}", pf: "${author_pf}", q: q }
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
      expect(solr_resp_doc_ids_only(author_query_params('Moiseĭ'))).to include(diacritic_name)
    end
    it 'retrieves book when diacritics excluded' do
      expect(solr_resp_doc_ids_only(author_query_params('Moisei'))).to include(diacritic_name)
    end
  end
  describe 'author 1xx field' do
    author = '484612'
    related_name = '5188770'
    let(:delta) { 0.2 }
    before(:all) do
      add_doc(author)
      add_doc(related_name)
    end
    it 'author 1xx match returned before 7xx match' do
      documents = solr_response(author_query_params('Fellbaum'))["response"]["docs"]
      expect(documents[0]["id"]).to include(author).before(related_name)
      expect(documents[0]["score"]).to be_within(delta).of(13.909944)
    end
  end
  after(:all) do
    delete_all
  end
end

RSpec.describe 'author keyword search' do
  context 'with solr8' do
    include_context 'solr8'
    include_examples 'shared author keyword search'
  end

    context 'with solr9' do
    include_context 'solr9'
    include_examples 'shared author keyword search'
  end
end
