require 'spec_helper'
require 'json'

docs = JSON.parse(File.read('spec/fixtures/cjk_map_solr_fixtures.json'))
stanford_docs = JSON.parse(File.read('spec/fixtures/cjk_stanford_fixtures.json'))

describe 'CJK character equivalence' do
  def add_single_field_doc char
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
      it "#{from} => #{to}" do
        expect(solr_resp_doc_ids_only({ 'fq'=>"cjk_mapped_to:#{from}"})).to include(id)
      end
      it "#{to} => #{from} (reverse)" do
        expect(solr_resp_doc_ids_only({ 'fq'=>"cjk_mapped_from:#{to}"})).to include(id)
      end
    end
  end
  describe 'Stanford direct mapping check' do
    before(:all) do
      delete_all
      @@solr.add(stanford_docs)
      @@solr.commit
    end
    stanford_docs.each do |map|
      from = map['cjk_mapped_from']
      to = map['cjk_mapped_to']
      id = map['id'].to_s
      it "#{from} => #{to}" do
        expect(solr_resp_doc_ids_only({ 'fq'=>"cjk_mapped_to:#{from}"})).to include(id)
      end
      it "#{to} => #{from} (reverse)" do
        expect(solr_resp_doc_ids_only({ 'fq'=>"cjk_mapped_from:#{to}"})).to include(id)
      end
    end
  end
  describe '4 character variations 壱 => 一, 壹 => 一, 弌 => 一' do
    it 'indirect mapping 壹 => 壱' do
      add_single_field_doc('壹')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:壱' })).to include('1')
    end
    it 'indirect mapping 壹 => 弌' do
      add_single_field_doc('弌')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:壹' })).to include('1')
    end
    it 'indirect mapping 壱 => 弌' do
      add_single_field_doc('壱')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:弌' })).to include('1')
    end
  end
  describe 'multi-character searches' do
    it '毛泽东思想 => 毛澤東思想' do
      add_single_field_doc('毛泽东思想')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:"毛澤東思想"' })).to include('1')
    end
    it '毛澤東思想 => 毛沢東思想' do
      add_single_field_doc('毛澤東思想')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:"毛沢東思想"' })).to include('1')
    end
    it '毛沢東思想 => 毛泽东思想' do
      add_single_field_doc('毛沢東思想')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:"毛泽东思想"' })).to include('1')
    end
  end
  describe 'punctuation marks are stripped' do
    it '『「｢「想』」｣」 => 」｣想｢「' do
      add_single_field_doc('『「｢「想』」｣」')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:"」｣想｢「"' })).to include('1')
    end
  end
  describe 'cjk "0"' do
    it '二〇〇〇 => 二０００' do
      add_single_field_doc('二０００')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:"二〇〇〇"' })).to include('1')
    end
    it '二０００ => 二〇〇〇' do
      add_single_field_doc('二〇〇〇')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:"二０００"' })).to include('1')
    end
  end
  describe 'mappings covered by other solr analyzers' do
    it '亜梅亜 => 亞梅亞' do
      add_single_field_doc('亜梅亜')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:"亞梅亞"' })).to include('1')
    end
    it '亞梅亞 => 亜梅亜' do
      add_single_field_doc('亞梅亞')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:"亜梅亜"' })).to include('1')
    end
    it '梅亜 => 梅亞' do
      add_single_field_doc('梅亜')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:"梅亞"' })).to include('1')
    end
    it '梅亜 => 梅亞' do
      add_single_field_doc('梅亞')
      expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:"梅亜"' })).to include('1')
    end
  end
  after(:all) do
    delete_all
  end
end