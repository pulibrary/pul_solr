require 'spec_helper'

describe 'title keyword search' do
  include_context 'solr8'
  before(:all) do
    solr(
      port: PulSolr.solr_connection[:test][:dss][:port],
      core: PulSolr.solr_connection[:test][:dss][:core]
    )
    delete_all
    add_doc 'resource1030'
  end

  it 'does not match against terms in subject_topic_facet' do
    expect(
      solr_resp_doc_ids_only({q: 'consumer finance', qf: '${title_qf}', pf: '${title_pf}'})
    ).not_to include 'resource1030'
  end

  it 'does not match against terms in blurb_t' do
    expect(
      solr_resp_doc_ids_only({q: 'Inter-city index report', qf: '${title_qf}', pf: '${title_pf}'})
    ).not_to include 'resource1030'
  end

  it 'matches against terms in title' do
    expect(
      solr_resp_doc_ids_only({q: 'ACCRA', qf: '${title_qf}', pf: '${title_pf}'})
    ).to include 'resource1030'
  end

  after(:all) { delete_all }
end
