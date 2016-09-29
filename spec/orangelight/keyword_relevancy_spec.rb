require 'spec_helper'
require 'json'

describe 'title subfield a boost' do
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
      expect(solr_resp_doc_ids_only({ 'q' => 'cage silence' }))
            .to include(silence_by_cage).as_first.document
    end
    it 'work matching 245a and not author comes before work matching author and not 245a' do
      expect(solr_resp_doc_ids_only({ 'q' => 'cage silence' }))
            .to include(sounds_like_silence_cage_in_title).before(four_by_cage)
    end
    it 'both match 245a but work that includes author in rest of title comes first' do
      expect(solr_resp_doc_ids_only({ 'q' => 'cage silence' }))
            .to include(sounds_like_silence_cage_in_title).before(no_such_thing_as_silence)
    end
  end
  after(:all) do
    delete_all
  end
end