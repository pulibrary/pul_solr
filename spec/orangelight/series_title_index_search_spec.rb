require 'spec_helper'

describe 'series title keyword search' do

  include_context 'solr_helpers'

  def series_title_query_params q
    { qf: "${series_title_qf}", pf: "${series_title_pf}", q: q }
  end
  before(:all) do
    delete_all
  end
    describe 'notes search' do
      let(:delta) { 0.02 }
      before(:all) do
        solr.add({ id: 1, series_title_index: 'Research in corpus and discourse' })
        solr.add({ id: 2, series_title_index: 'Scientific research', series_ae_index: 'Scientific research' })
        solr.add({ id: 3, series_title_index: 'Research' })
        solr.commit
      end
      it 'notes search scores match expected vaules' do
        documents = solr_response(series_title_query_params('research'))["response"]["docs"]

        expect(documents[0]["score"]).to be_within(delta).of(0.8970048)
        expect(documents[1]["score"]).to be_within(delta).of(0.746596)
        expect(documents[2]["score"]).to be_within(delta).of(0.4916637)
      end
    end
    after(:all) do
      delete_all
    end
  end