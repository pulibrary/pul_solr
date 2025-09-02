require 'spec_helper'
require 'json'

RSpec.shared_examples 'shared stripping punctuation surrounded by whitespace' do

  def qf_pf_params q, field
    {qf: "${#{field}_qf}", pf: "${#{field}_pf}", q: q}
  end

  before(:all) do
    delete_all
    @china_and_angola = '7196990'
    add_doc(@china_and_angola)
  end
  describe 'default text query' do
    it 'matches when colon is included at end of query word' do
      expect(solr_resp_doc_ids_only({ 'q' => 'China and Angola: marriage convenience' })).to include(@china_and_angola)
    end
    it 'matches when colon is surrounded by whitespace' do
      expect(solr_resp_doc_ids_only({ 'q' => 'China and Angola : marriage convenience' })).to include(@china_and_angola)
    end
  end
  describe 'title query' do
    it 'matches when colon is included at end of query word' do
      expect(solr_resp_doc_ids_only(qf_pf_params('China and Angola: marriage convenience',
                                                        'title'))).to include(@china_and_angola)
    end
    it 'matches when colon is surrounded by whitespace' do
      expect(solr_resp_doc_ids_only(qf_pf_params('China and Angola : marriage convenience',
                                                        'title'))).to include(@china_and_angola)
    end
  end
  describe 'author query' do
    it 'matches when exclamation point is included at end of query word' do
      expect(solr_resp_doc_ids_only(qf_pf_params('Power! Marcus',
                                                        'author'))).to include(@china_and_angola)
    end
    it 'matches when exclamation point is surrounded by whitespace' do
      expect(solr_resp_doc_ids_only(qf_pf_params('Power ! Marcus',
                                                        'author'))).to include(@china_and_angola)
    end
  end
  describe 'subject query' do
    it 'matches when undesired character is included at end of query word' do
      expect(solr_resp_doc_ids_only(qf_pf_params('foreign economic relations% angola',
                                                        'subject'))).to include(@china_and_angola)
    end
    it 'matches when undesired character is surrounded by whitespace' do
      expect(solr_resp_doc_ids_only(qf_pf_params('foreign economic relations % angola',
                                                        'subject'))).to include(@china_and_angola)
    end
  end
  after(:all) do
    delete_all
  end
end

RSpec.describe 'protected words' do
  context 'with solr8' do
    include_context 'solr8'
    include_examples 'shared stripping punctuation surrounded by whitespace'
  end

    context 'with solr9' do
    include_context 'solr9'
    include_examples 'shared stripping punctuation surrounded by whitespace'
  end
end
