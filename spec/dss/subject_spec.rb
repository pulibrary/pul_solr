require 'spec_helper'

describe 'title keyword search' do
  include_context 'solr9'
  before(:all) do
    solr(
      port: PulSolr.solr_connection[:test][:dss][:port],
      core: PulSolr.solr_connection[:test][:dss][:core]
    )
    delete_all
    add_doc 'resource1030'
  end

  it 'can display subject_topic_facet field' do
    expect(
      solr_response({q: 'consumer finance', fl: 'id,subject_topic_facet'})['response']['docs']
    ).to eq([{'id' => 'resource1030', 'subject_topic_facet' => ['Consumer Spending & Finance']}])
  end

  after(:all) { delete_all }
end
