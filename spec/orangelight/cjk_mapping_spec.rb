require 'spec_helper'
require 'json'

docs = JSON.parse(File.read('spec/fixtures/cjk_map_solr_fixtures.json'))

describe 'CJK character equivalence' do
  def add_single_char_doc char
    @@solr.add({ id: 1, cjk_title: char })
    @@solr.commit
  end
  before(:all) do
    delete_all
    @@solr.add(docs)
    @@solr.commit
  end
  describe 'Direct mapping check' do
    docs.each do |map|
      from = map['cjk_mapped_from']
      to = map['cjk_mapped_to']
      id = map['id'].to_s
      if map['cjk_skip']
        xit "#{from} => #{to}"
      else
        it "#{from} => #{to}" do
          expect(solr_resp_doc_ids_only({ 'fq'=>"cjk_mapped_to:#{from}"})).to include(id)
        end
        it "#{to} => #{from} (reverse)" do
          expect(solr_resp_doc_ids_only({ 'fq'=>"cjk_mapped_from:#{to}"})).to include(id)
        end
      end
    end
  end
  describe '4 character variations 壱 => 一, 壹 => 一, 弌 => 一' do
    before(:all) do
      delete_all
    end
    it 'indirect mapping 壹 => 壱' do
      add_single_char_doc('壹')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:壱' })).to include('1')
    end
    it 'indirect mapping 壹 => 弌' do
      add_single_char_doc('弌')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:壹' })).to include('1')
    end
    it 'indirect mapping 壱 => 弌' do
      add_single_char_doc('壱')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:弌' })).to include('1')
    end
  end
  describe 'multi-character searches' do
    before(:all) do
      delete_all
    end
    it 'indirect mapping 壹 => 壱' do
      add_single_char_doc('壹')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:壱' })).to include('1')
    end
    it 'indirect mapping 壹 => 弌' do
      add_single_char_doc('弌')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:壹' })).to include('1')
    end
    it 'indirect mapping 壱 => 弌' do
      add_single_char_doc('壱')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:弌' })).to include('1')
    end
  end
  after(:all) do
    delete_all
  end
end
