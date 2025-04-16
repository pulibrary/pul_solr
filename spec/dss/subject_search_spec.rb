require 'spec_helper'

describe 'subject keyword search' do
  include_context 'solr_helpers'
  before(:all) do
    solr(
      port: PulSolr.solr_connection[:test][:dss][:port],
      core: PulSolr.solr_connection[:test][:dss][:core]
    )
    delete_all
    add_doc 'resource1030'
  end

  it 'matches against terms in subject_topic_facet' do
    expect(
      solr_resp_doc_ids_only({q: 'consumer finance', qf: '${subject_qf}', pf: '${subject_pf}'})
    ).to include 'resource1030'
  end

  it 'does not match against terms in blurb_t' do
    expect(
      solr_resp_doc_ids_only({q: 'Inter-city index report', qf: '${subject_qf}', pf: '${subject_pf}'})
    ).not_to include 'resource1030'
  end

  it 'does not match against terms in title' do
    expect(
      solr_resp_doc_ids_only({q: 'ACCRA', qf: '${subject_qf}', pf: '${subject_pf}'})
    ).not_to include 'resource1030'
  end

  after(:all) { delete_all }
end
