require 'spec_helper'
require 'json'

describe 'title keyword search' do
  def title_query_string q
    "{!qf=$title_qf pf=$title_pf}#{q}"
  end
  before(:all) do
    delete_all
  end
  describe 'title_display field' do
    patterns_in_nature = '1355809'
    before(:all) do
      add_doc(patterns_in_nature)
    end
    it 'retrieves book when first word in title_display is searched' do
      expect(solr_resp_doc_ids_only({ 'q' => title_query_string('Patterns') })).to include(patterns_in_nature)
    end
    it 'retrieves book with multiword query of title_display field' do
      expect(solr_resp_doc_ids_only({ 'q' => title_query_string('Patterns in nature by') })).to include(patterns_in_nature)
    end
    it 'casing does not impact search' do
      expect(solr_resp_doc_ids_only({ 'q' => title_query_string('pAttErnS iN NatURE') })).to include(patterns_in_nature)
    end
    it 'title keywords are not required to appear in the same order as title_display field' do
      expect(solr_resp_doc_ids_only({ 'q' => title_query_string('stevens patterns') })).to include(patterns_in_nature)
    end
    it 'title keywords are stemmed' do
      expect(solr_resp_doc_ids_only({ 'q' => title_query_string('steven pattern') })).to include(patterns_in_nature)
    end
    it 'fails to match when word in query is missing from title_display field (mm 6<90%)' do
      expect(solr_resp_doc_ids_only({ 'q' => title_query_string('pattern in nature by peter rabbit') })).not_to include(patterns_in_nature)
    end
  end
  describe 'series_title_index field' do
    mozart_series = '8919079'
    series_title = 'Neue Ausgabe samtlicher Werke'
    before(:all) do
      add_doc(mozart_series)
    end
    it 'series title is not in 245' do
      expect(solr_resp_doc_ids_only({ 'fq' => "title_display:\"#{series_title}\"" })).not_to include(mozart_series)
    end
    it 'series title is in 490' do
      expect(solr_resp_doc_ids_only({ 'fq' => "series_title_index:\"#{series_title}\"" })).to include(mozart_series)
    end
    it 'title keyword search matches 490 field' do
      expect(solr_resp_doc_ids_only({ 'q' => title_query_string(series_title) })).to include(mozart_series)
    end
  end
  after(:all) do
    delete_all
  end
end
