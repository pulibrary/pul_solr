require 'spec_helper'

describe 'boolean search' do
  include_context 'solr9'
  before(:all) do
    solr(
      port: PulSolr.solr_connection[:test][:dss][:port],
      core: PulSolr.solr_connection[:test][:dss][:core]
    )
    delete_all
  end

  it 'can do a boolean OR search' do
    solr.add({ id: 1, title_display: ['Korea Foundation'] })
    solr.add({ id: 2, title_display: ['Survey on Time Use and Leisure Activities (1996+) [Japan]'] })
    solr.add({ id: 3, title_display: ['Immigration Policy: 1783-2010 [Argentina, Australia, Brazil, Canada, France, Germany, Hong Kong, Japan, Kuwait, the Netherlands, New Zealand, Saudi Arabia, Singapore, South Africa, South Korea, Switzerland, Taiwan, United Kingdom, United States]']})
    solr.commit
    results = solr_resp_doc_ids_only({q: 'Korea OR Japan'})['response']['docs'].map { it['id'] }
    expect(results).to include '1', '2', '3'
  end

  it 'can do a boolean AND search' do
    solr.add({ id: 1, title_display: ['Korea Foundation'] })
    solr.add({ id: 2, title_display: ['Survey on Time Use and Leisure Activities (1996+) [Japan]'] })
    solr.add({ id: 3, title_display: ['Immigration Policy: 1783-2010 [Argentina, Australia, Brazil, Canada, France, Germany, Hong Kong, Japan, Kuwait, the Netherlands, New Zealand, Saudi Arabia, Singapore, South Africa, South Korea, Switzerland, Taiwan, United Kingdom, United States]']})
    solr.commit

    results = solr_resp_doc_ids_only({q: 'Korea AND Japan'})['response']['docs'].map { it['id'] }
    expect(results).not_to include '1', '2'
    expect(results).to include '3'
  end


  after(:all) { delete_all }
end
