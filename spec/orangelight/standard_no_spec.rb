require 'spec_helper'
require 'json'

docs = JSON.parse(File.read('spec/fixtures/cjk_map_solr_fixtures.json'))

describe 'standard no keyword search' do
  before(:all) do
    delete_all
  end
  describe 'isbn' do
    isbn_normalized = '9784103534228'
    isbn_invalid = '9791032000373'
    before(:all) do
      @@solr.add({ id: 1, isbn_s: [isbn_normalized, isbn_invalid] })
      @@solr.commit
    end
    it 'isbn is indexed' do
      expect(solr_resp_doc_ids_only({ 'q' => isbn_normalized })).to include('1')
    end
    it 'dashes can be included in query' do
      expect(solr_resp_doc_ids_only({ 'q' => '978-4103534-228' })).to include('1')
    end
    it 'non-isbn characters are stripped' do
      expect(solr_resp_doc_ids_only({ 'q' => '9784103534228 (v. 1)' })).to include('1')
    end
    it '10-digit resolves to 13 digit' do
      expect(solr_resp_doc_ids_only({ 'q' => '4103534222' })).to include('1')
    end
    it 'isbns the normalizer deems invalid are still retrievable' do
      expect(solr_resp_doc_ids_only({ 'q' => isbn_invalid })).to include('1')
    end
  end
  describe 'issn_s' do
    science_00368075 = '857469'
    science_other_00368075 = '2106846'
    science_787link = '2063044'
    science_10959203 = '8606659'
    issn_normalized = '00368075'
    before(:all) do
      add_doc(science_00368075)
      add_doc(science_other_00368075)
      add_doc(science_787link)
      add_doc(science_10959203)
    end
    it 'issn is indexed' do
      expect(solr_resp_doc_ids_only({ 'q' => issn_normalized })).to include(science_00368075)
    end
    it 'issn matches in linked record fields' do
      expect(solr_resp_doc_ids_only({ 'q' => issn_normalized })).to include(science_10959203)
    end
    it 'dashes can be included in query' do
      expect(solr_resp_doc_ids_only({ 'q' => '0036-8075' })).to include(science_other_00368075)
    end
    it 'issn_s matches are more relevant than issn matches in linked fields' do
      expect(solr_resp_doc_ids_only({ 'q' => '0036-8075' })).to include(science_00368075).in_first(2).results
      expect(solr_resp_doc_ids_only({ 'q' => '0036-8075' })).to include(science_other_00368075).in_first(2).results
    end
  end
  describe 'lccn_s' do
    lccn_85000002 = '85000002'
    lccn_2001000002 = '2001000002'
    lccn_75425165 = '75425165'
    before(:all) do
      @@solr.add({ id: 1, lccn_s: [lccn_75425165, lccn_2001000002, lccn_85000002] })
      @@solr.commit
    end
    it 'lccn is indexed' do
      expect(solr_resp_doc_ids_only({ 'q' => lccn_75425165 })).to include('1')
    end
    it 'whitespace can be included in query' do
      expect(solr_resp_doc_ids_only({ 'q' => ' 85000002 ' })).to include('1')
    end
    it 'dashes can be included in query' do
      expect(solr_resp_doc_ids_only({ 'q' => '2001-000002' })).to include('1')
    end
    it 'extra characters are stripped' do
      expect(solr_resp_doc_ids_only({ 'q' => '75-425165//r75' })).to include('1')
    end
    it 'smaller lccns are padded with 0s for normalized length' do
      expect(solr_resp_doc_ids_only({ 'q' => '85-2 ' })).to include('1')
    end
  end
  after(:all) do
    delete_all
  end
end
