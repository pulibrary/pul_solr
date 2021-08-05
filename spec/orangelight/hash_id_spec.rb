require 'spec_helper'
require 'json'

describe 'hash id field solrconfig update handler' do
  include_context 'solr_helpers'

  before(:all) do
    delete_all
  end
  describe 'all documents get a hashed_id_s field after indexing' do
    before(:all) do
      solr.add({ id: 1, title_display: 'Any solr document' })
      solr.commit
    end
    it 'hashed id field is indexed' do
      pending "Disabled until we implement dynamic site maps."
      expect(solr_resp_doc_ids_only({ 'q': 'hashed_id_s:*'  })).to include('1')
    end

  end
  after(:all) do
    delete_all
  end
end
