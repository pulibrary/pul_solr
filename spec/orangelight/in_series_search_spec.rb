require 'spec_helper'

RSpec.shared_examples 'shared in series keyword search' do

  def in_series_query_params q
    { qf: "${in_series_qf}", pf: "${in_series_pf}", q: "\"#{q}\"" }
  end
  before(:all) do
    delete_all
  end
  describe 'more_in_this_series field' do
    silence = '6081592'
    avant_garde = '212556'
    health = '99125315781206421'
    let(:delta) { 0.2 }
    before(:all) do
      add_doc(silence)
      add_doc(avant_garde)
      add_doc(health)
    end
    it 'more_in_this_series scores match expected vaules' do
      documents = solr_response(in_series_query_params('Theory and history of literature'))["response"]["docs"]

      expect(documents[0]["score"]).to be_within(delta).of(50.980827)
    end
    end
    after(:all) do
      delete_all
    end
  end

RSpec.describe 'in series keyword search' do
  context 'with solr8' do
    include_context 'solr8'
    include_examples 'shared in series keyword search'
  end

    context 'with solr9' do
    include_context 'solr9'
    include_examples 'shared in series keyword search'
  end
end
