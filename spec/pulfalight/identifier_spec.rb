require 'spec_helper'
require 'json'

describe 'all fields search for id value' do

  include_context 'solr_helpers'

  def query_params q
    { q: q }
  end
  before(:all) do
    @solr = RSolr.connect :url => "http://127.0.0.1:8888/solr/pulfalight-staging", :read_timeout => 9999999
    delete_all
  end
  describe 'collection and component ids' do
    tc_component_name = 'TC071TC071_c00001'
    tc_collection_name = 'TC071'
    bad_tc_collection_name = 'TC081'

    # collection >> sub-collections called subgroups >> series >> components
    mc_collection_name = 'MC001'
    mc_subgroup_name = 'MC001-04'
    mc_series_name = 'MC001-02-04'

    before(:all) do
      add_doc(tc_component_name)
      add_doc(tc_collection_name)
      add_doc(bad_tc_collection_name)

      add_doc(mc_collection_name)
      add_doc(mc_subgroup_name)
      add_doc(mc_series_name)
    end

    it 'retrieves both collection and component when search for collection_id' do
      response = solr_response(query_params('TC071').merge('fl' => 'id', 'facet' => 'false'))
      expect(response.to_s).to include(tc_collection_name)
      expect(response.to_s).to include(tc_component_name)
      expect(response.to_s).not_to include("\"#{bad_tc_collection_name}\"")
    end

    it 'tests case insensitivity' do
      response = solr_response(query_params('tc071').merge('fl' => 'id', 'facet' => 'false'))
      expect(response.to_s).to include(tc_collection_name)
      expect(response.to_s).to include(tc_component_name)
      expect(response.to_s).not_to include("\"#{bad_tc_collection_name}\"")
    end

    it 'retrieves only component when search for component_id' do
      response = solr_response(query_params('TC071TC071_c00001').merge('fl' => 'id', 'facet' => 'false'))
      expect(response.to_s).to include(tc_component_name)
      expect(response.to_s).not_to include("\"#{tc_collection_name}\"")
    end

    it 'retrieves component even when search for incomplete component id' do
      response = solr_response(query_params('TC071_c00001').merge('fl' => 'id', 'facet' => 'false'))
      expect(response.to_s).to include(tc_component_name)
      expect(response.to_s).not_to include("\"#{tc_collection_name}\"")
    end

    it 'does not retrieve collection when search for TC 071' do
      response = solr_response(query_params('TC 071').merge('fl' => 'id', 'facet' => 'false'))
      expect(response.to_s).not_to include("\"#{tc_collection_name}\"")
      expect(response.to_s).not_to include("\"#{bad_tc_collection_name}\"")
    end

    it 'retrieves only subgroup and not series when search for series id' do
      response = solr_response(query_params('MC001.04').merge('fl' => 'id', 'facet' => 'false'))
      expect(response.to_s).to include("\"#{mc_subgroup_name}\"")
      expect(response.to_s).not_to include("\"#{mc_series_name}\"")
    end

    it 'retrieves only collection and neither subgroup nor series when search for collection id' do
      response = solr_response(query_params('MC001').merge('fl' => 'id', 'facet' => 'false'))
      expect(response.to_s).to include("\"#{mc_collection_name}\"")
      expect(response.to_s).not_to include("\"#{mc_subgroup_name}\"")
      expect(response.to_s).not_to include("\"#{mc_series_name}\"")
    end

   end
  after(:all) do
    delete_all
  end
end
