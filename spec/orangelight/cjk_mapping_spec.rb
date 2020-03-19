require 'spec_helper'
require 'json'

docs = JSON.parse(File.read('spec/fixtures/cjk_map_solr_fixtures.json'))
stanford_docs = JSON.parse(File.read('spec/fixtures/cjk_stanford_fixtures.json'))

describe 'CJK character equivalence' do
  include_context 'solr_helpers'

  def add_single_field_doc char
    solr.add({ id: 1, cjk_title: char })
    solr.commit
  end
  before(:all) do
    delete_all
    solr.add(docs)
    solr.commit
  end
  describe 'Direct mapping check' do
    before(:all) do
      delete_all
      solr.add(docs)
      solr.commit
    end
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
      solr.add(stanford_docs)
      solr.commit
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
    describe "Chinese" do
      it '毛沢東思想 => 毛泽东思想' do
        add_single_field_doc('毛沢東思想')
        expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:"毛泽东思想"' })).to include('1')
      end
      it 'can find this particular title' do
        titles = [
          '長沙走馬楼三國吴简 / 長沙市文物考古研究所, 中國文物研究所, 北京大學歷史學系走馬樓簡牘整理組編著.',
          '走馬楼三國吴简',
          '嘉禾吏民田家[bie]',
          '竹簡.'
        ]
        add_single_field_doc(titles)
        params = {qf: 'cjk_title', pf: 'cjk_title', q: '长沙走马楼三国吴简'}
        expect(solr_resp_doc_ids_only(params)).to include('1')
      end
      it "can find notes" do
        notes = '闲话'
        solr.add({ id: 1, notes_index: '閑話' })
        solr.commit
        params = {qf: '${notes_qf}', pf: '${notes_pf}', q: notes}
        expect(solr_resp_doc_ids_only(params)).to include('1')
      end
    end
    describe "Korean" do
      it '고려의후삼국통일과후백제 => 고려의 후삼국 통일과 후백제' do
        add_single_field_doc('고려의후삼국통일과후백제')
        expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:"고려의 후삼국 통일과"' })).to include('1')
      end
      it '한국사 => 한국' do
        add_single_field_doc('한국사')
        expect(solr_resp_doc_ids_only({ 'fq'=>'cjk_title:"한국"' })).to include('1')
      end
    end
    describe "Japanese Hiragana" do
      it 'における => おける' do
        add_single_field_doc('における')
        # This works, but not because of cjk_text. It works because of the
        # standard tokenizer on the text field.
        expect(solr_resp_doc_ids_only({ 'q'=>'おける' })).to include('1')
      end
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
  describe 'mapping applied to search fields' do
    def qf_pf_params q, field
      {qf: "${#{field}_qf}", pf: "${#{field}_pf}", q: q}
    end
    it '国史大辞典 => 國史大辭典 left anchor' do
      solr.add({ id: 1, title_la: '國史大辭典' })
      solr.commit
      expect(solr_resp_doc_ids_only(qf_pf_params("国史大辞典","left_anchor"))).to include('1')
    end
    it '三晋出版社 => 三晉出版社 publisher' do
      solr.add({ id: 1, pub_created_vern_display: '三晋出版社' })
      solr.commit
      expect(solr_resp_doc_ids_only(qf_pf_params("三晉出版社", "publisher"))).to include('1')
    end
    it '巴蜀書社 => 巴蜀书社  notes' do
      solr.add({ id: 1, cjk_notes: '巴蜀書社' })
      solr.commit
      expect(solr_resp_doc_ids_only(qf_pf_params("巴蜀书社 ", "notes"))).to include('1')
    end
    it '鳳凰出版社 => 凤凰出版社  series title' do
      solr.add({ id: 1, cjk_series_title: '鳳凰出版社' })
      solr.commit
      expect(solr_resp_doc_ids_only(qf_pf_params("凤凰出版社 ", "series_title"))).to include('1')
    end
  end

  after(:all) do
    delete_all
  end
end
