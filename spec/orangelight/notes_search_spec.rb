require 'spec_helper'

describe 'notes keyword search' do

  include_context 'solr_helpers'

  def notes_query_params q
    { qf: "${notes_qf}", pf: "${notes_pf}", q: q }
  end
  before(:all) do
    delete_all
  end
    describe 'notes search' do
      let(:delta) { 0.02 }
      before(:all) do
        solr.add({ id: 1, cjk_notes: 'Translation' })
        solr.add({ id: 2, cjk_notes: 'Translation from Japanese' })
        solr.add({ id: 3, cjk_notes: 'English translation' })
        solr.commit
      end
      it 'notes search scores match expected vaules' do
        documents = solr_response(notes_query_params('translation'))["response"]["docs"]

        expect(documents[0]["score"]).to be_within(delta).of(0.16786805)
        expect(documents[1]["score"]).to be_within(delta).of(0.13353139)
        expect(documents[2]["score"]).to be_within(delta).of(0.110856235)
      end
    end
    after(:all) do
      delete_all
    end
  end