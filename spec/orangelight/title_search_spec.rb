require 'spec_helper'
require 'json'

def title_query_string q
  "{!qf=$title_qf pf=$title_pf}#{q}"
end

def left_anchor_query_string q
  "{!qf=$left_anchor_qf pf=$left_anchor_pf}#{q}*"
end

describe 'title keyword search' do
  include_context 'solr_helpers'

  before do
    delete_all
  end

  describe 'title_display field' do
    let(:patterns_in_nature) { '1355809' }

    before do
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
    let(:mozart_series) { '8919079' }
    let(:series_title) { 'Neue Ausgabe samtlicher Werke' }

    before do
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

  describe 'title_a_index field relevancy' do
    let(:silence) { '1228819' }
    let(:four_silence_subtitle) { '4789869' }
    let(:sounds_like_silence) { '7381137' }

    before do
      add_doc(silence)
      add_doc(four_silence_subtitle)
      add_doc(sounds_like_silence)
    end

    it 'exact 245a match more relevant than longer 245a field' do
      expect(solr_resp_doc_ids_only({ 'q' => title_query_string('silence') }))
            .to include(silence).before(sounds_like_silence)
    end
    it '245a match more relevant than subtitle match' do
      expect(solr_resp_doc_ids_only({ 'q' => title_query_string('silence') }))
            .to include(sounds_like_silence).before(four_silence_subtitle)
    end
  end

  describe 'title exact match relevancy' do
    let(:first_science) { '9774575' }
    let(:science_and_spirit) { '9805613' }
    let(:second_science) { '857469' }

    before do
      add_doc(first_science)
      add_doc(science_and_spirit)
      add_doc(second_science)
    end

    it 'exact matches Science' do
      expect(solr_resp_doc_ids_only({ 'q' => title_query_string('Science'), 'sort' => 'score DESC'})["response"]["docs"].last)
            .to eq({"id" => science_and_spirit})
    end
    it 'left anchor exact matches Science' do
      expect(solr_resp_doc_ids_only({ 'q' => left_anchor_query_string('Science'), 'sort' => 'score DESC'})["response"]["docs"].last)
            .to eq({"id" => science_and_spirit})
    end

    context 'with a title which includes whitespace around punctuation marks' do
      let(:idioms_and_colloc) { '5188770' }

      before do
        add_doc(idioms_and_colloc)
      end

      it 'matches titles without the whitespace' do
        expect(solr_resp_doc_ids_only({ 'q' => left_anchor_query_string('Idioms\ and\ collocations\ \:\ corpus-based'), 'sort' => 'score DESC'})["response"]["docs"].last)
              .to eq({"id" => idioms_and_colloc})

        expect(solr_resp_doc_ids_only({ 'q' => left_anchor_query_string('Idioms\ and\ collocations\:\ corpus-based'), 'sort' => 'score DESC'})["response"]["docs"].last)
              .to eq({"id" => idioms_and_colloc})
      end
    end
  end

  describe 'handling for titles which contain dashes' do
    let(:bibid) { '212556' }
    let(:query) { title_query_string('theory of the avant garde') }
    let(:parameters) do
      {
        'q' => query,
        'sort' => 'score DESC'
      }
    end
    let(:response) { solr_resp_doc_ids_only(parameters) }
    let(:documents) { response["response"]["docs"] }

    before do
      add_doc(bibid)
    end

    it 'finds titles containing dashes' do
      expect(documents.last).to eq({ "id" => bibid })
    end

    context 'when a query contains a dash character' do
      let(:query) { title_query_string('theory of the avant-garde') }

      it 'finds titles containing dashes' do
        expect(documents.last).to eq({ "id" => bibid })
      end
    end
  end

  after do
    delete_all
  end
end

describe 'title_l search' do
  include_context 'solr_helpers'

  let(:response) { solr_resp_doc_ids_only(params)['response'] }
  let(:docs) { response['docs'] }

  before do
    solr.add({ id: 1, title_display: [title] })
    solr.commit
  end

  context 'when colon excluded in query' do
    let(:title) { 'Photo-secession : the golden age' }
    let(:params) do
      { 'q' => left_anchor_query_string('Photo-secession\\ \\ the') }
    end

    it 'matches when colon excluded in query' do
      expect(docs).to eq([{ "id" => "1" }])
    end
  end
  context 'when dash is excluded in query' do
    let(:title) { 'Photo-secession : the golden age' }
    let(:params) do
      { 'q' => left_anchor_query_string('Photosecession\\ the') }
    end

    it 'matches when dash is excluded in query' do
      expect(docs).to eq([{ "id" => "1" }])
    end
  end

  context 'Tests that search is left-anchored' do
    let(:title) { 'Katja Strunz : Zeittraum' }
    let(:params) do
      { 'q' => left_anchor_query_string('Katja\\ Strunz\\ :\\ Zeittraum') }
    end

    it 'matches when the query includes first word of title' do
      expect(docs).to eq([{ "id" => "1" }])
    end
  end

  context 'Tests that cjk searches work with wildcards' do
    let(:title) { '浄名玄論 / 京都国' }
    let(:params) do
      { 'q' => left_anchor_query_string('浄名玄') }
    end

    it 'matches when the query includes first word of title' do
      expect(docs).to eq([{ "id" => "1" }])
    end
  end

  context 'when dash is excluded in query' do
    let(:title) { 'Katja Strunz : Zeittraum' }
    let(:params) do
      { 'q' => left_anchor_query_string('Strunz') }
    end

    it 'does not match when first word of title is not in query' do
      expect(docs).to eq([])
    end
  end

  after do
    delete_all
  end
end
