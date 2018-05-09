require 'spec_helper'
require 'json'

describe 'title subfield a boost' do
  include_context 'solr_helpers'

  before(:all) do
    delete_all
  end
  context 'when performing a keyword search combining author and title' do
    silence_by_cage = '1228819'
    anarchy_silence_by_cage = '6184414'
    four_by_cage = '4789869'
    no_such_thing_as_silence = '6081592'
    sounds_like_silence_cage_in_title = '7381137'
    before(:all) do
      add_doc(silence_by_cage)
      add_doc(anarchy_silence_by_cage)
      add_doc(four_by_cage)
      add_doc(no_such_thing_as_silence)
      add_doc(sounds_like_silence_cage_in_title)
    end
    it 'work matching 245a and author comes first' do
      expect(solr_resp_doc_ids_only('q' => 'cage silence'))
        .to include(silence_by_cage).as_first.document
    end
    it 'works matching exact titles first' do
      expect(solr_resp_doc_ids_only('q' => 'Silence'))
        .to include(silence_by_cage).as_first.document
    end
    it 'work matching 245a and not author comes before work matching author and not 245a' do
      expect(solr_resp_doc_ids_only('q' => 'cage silence'))
        .to include(sounds_like_silence_cage_in_title).before(four_by_cage)
    end
    it 'both match 245a but work that includes author in rest of title comes first' do
      expect(solr_resp_doc_ids_only('q' => 'cage silence'))
        .to include(sounds_like_silence_cage_in_title).before(no_such_thing_as_silence)
    end
  end
  context 'when performing a keyword search with local and scsb results' do
    capitalism_socialism_democracy_1 = '1225885'
    capitalism_socialism_democracy_2 = '1225884'
    capitalism_socialism_democracy_3 = 'SCSB-3330744'
    before(:all) do
      add_doc(capitalism_socialism_democracy_1)
      add_doc(capitalism_socialism_democracy_2)
      add_doc(capitalism_socialism_democracy_3)
    end
    it 'sorts scsb record after local records' do
      expect(solr_resp_doc_ids_only('q' => 'capitalism socialism democracy'))
        .to include(capitalism_socialism_democracy_1).before(capitalism_socialism_democracy_3)
      expect(solr_resp_doc_ids_only('q' => 'capitalism socialism democracy'))
        .to include(capitalism_socialism_democracy_2).before(capitalism_socialism_democracy_3)
    end
  end
  context 'when performing CJK searches' do
    exact_match = '6581897'
    variant_exact_match = '1831578'
    japanese_exact_match = '3175938'
    left_anchor_match = '4216926'
    non_phrase_match = '4276901'
    before(:all) do
      add_doc(exact_match)
      add_doc(variant_exact_match)
      add_doc(japanese_exact_match)
      add_doc(left_anchor_match)
      add_doc(non_phrase_match)
    end
    it 'records that contain non-phrase mathces appear last' do
      expect(solr_resp_doc_ids_only('q' => '诗经研究', 'sort' => 'score ASC'))
        .to include(non_phrase_match).as_first.document
    end
    it 'work matching full 245 as phrase comes first' do
      expect(solr_resp_doc_ids_only('q' => '诗经研究'))
        .to include(japanese_exact_match).as_first.document
    end
  end
  after(:all) do
    delete_all
  end
end
