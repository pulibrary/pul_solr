require 'spec_helper'
require 'json'

describe 'title keyword search' do

  include_context 'solr_helpers'

  def title_query_string q
    "{!qf=$title_qf pf=$title_pf}#{q}"
  end
  def title_query_params q
    { qf: "${title_qf}", pf: "${title_pf}", q: q }
  end
  before(:all) do
    solr(port: ENV['CI'] ? "8983" : ENV['lando_pulmap_test_solr_conn_port'])
    delete_all
  end
  describe 'diacritics' do
    diacritic_name = 'princeton-4j03d346d'
    before(:all) do
      add_doc(diacritic_name)
    end
    it 'retrieves record when diacritics included' do
      response = solr_response(title_query_params('Abbottābād').merge('fl' => 'uuid', 'facet' => 'false'))
      expect(response.to_s).to include(diacritic_name)
    end
    it 'retrieves record when diacritics excluded' do
      response = solr_response(title_query_params('Abbottabad').merge('fl' => 'uuid', 'facet' => 'false'))
      expect(response.to_s).to include(diacritic_name)
    end
  end
  after(:all) do
    delete_all
  end
end

