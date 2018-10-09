require 'spec_helper'
require 'json'

describe 'title keyword search' do

  include_context 'solr_helpers'

  def title_query_string q
    "{!qf=$title_qf pf=$title_pf}#{q}"
  end
  before(:all) do
    delete_all
    @solr =  RSolr.connect :url => "http://127.0.0.1:8888/solr/pulmap", :read_timeout => 9999999
  end
  describe 'diacritics' do
    diacritic_name = 'princeton-4j03d346d'
    before(:all) do
      add_doc(diacritic_name)
    end
    it 'retrieves record when diacritics included' do
      response = solr_response({ 'q' => title_query_string('Abbottābād'), 'fl' => 'uuid', 'facet' => 'false' })
      expect(response.to_s).to include(diacritic_name)
    end
    it 'retrieves record when diacritics excluded' do
      response = solr_response({ 'q' => title_query_string('Abbottabad'), 'fl' => 'uuid', 'facet' => 'false' })
      expect(response.to_s).to include(diacritic_name)
    end
  end
  after(:all) do
    delete_all
  end
end

