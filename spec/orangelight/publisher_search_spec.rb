require 'spec_helper'

describe 'publisher keyword search' do

  include_context 'solr_helpers'

  def publisher_query_params q
    { qf: "${publisher_qf}", pf: "${publisher_pf}", q: q }
  end
  before(:all) do
    delete_all
  end
    describe 'publisher search' do
      silence = '6081592'
      avant_garde = '212556'
      health = '99125315781206421'
      let(:delta) { 0.2 }
      before(:all) do
        add_doc(silence)
        add_doc(avant_garde)
        add_doc(health)
      end
      it 'publisher search scores match expected vaules' do
        documents = solr_response(publisher_query_params('University'))["response"]["docs"]

        expect(documents[0]["score"]).to be_within(delta).of(50.499176)
        expect(documents[1]["score"]).to be_within(delta).of(0.4700036)
      end
    end
    after(:all) do
      delete_all
    end
  end