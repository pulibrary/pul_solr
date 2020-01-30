require 'spec_helper'
require 'json'

describe 'subject keyword search' do
  include_context 'solr_helpers'

  def subject_query_params q
    {qf: "${subject_qf}", pf: "${subject_pf}", q: q}
  end

  before(:all) do
    delete_all
  end
  describe 'diacritics' do
    diacritic_subject = '454035'
    before(:all) do
      add_doc(diacritic_subject)
    end
    it 'retrieves book when diacritics included' do
      expect(solr_resp_doc_ids_only(subject_query_params('ʻUthmān, ʻUthmān'))).to include(diacritic_subject)
    end
    it 'retrieves book when diacritics excluded' do
      expect(solr_resp_doc_ids_only(subject_query_params('Uthman'))).to include(diacritic_subject)
    end
  end
  describe 'stopwords' do
    stop_word_subject = '1332805'
    before(:all) do
      add_doc(stop_word_subject)
    end
    it 'retrieves book when stop words included' do
      expect(solr_resp_doc_ids_only(subject_query_params('image of god'))).to include(stop_word_subject)
    end
    it 'retrieves book when stop words excluded' do
      expect(solr_resp_doc_ids_only(subject_query_params('image god'))).to include(stop_word_subject)
    end
  end
  describe 'stemming disabled' do
    before(:all) do
      solr.add({ id: 1, subject_display: 'Biographical films—United States' })
      solr.commit
    end
    it 'matches heading terms exactly' do
      expect(solr_resp_doc_ids_only(subject_query_params('Biographical films United States'))).to include('1')
    end
    it 'stemmed form included in all fields' do
      expect(solr_resp_doc_ids_only({ 'q' => 'Biograph film Unit State' })).to include('1')
    end
    it 'stemmed form excluded from subject field' do
      expect(solr_resp_doc_ids_only(subject_query_params('Biograph film Unit State'))).not_to include('1')
    end
  end
  after(:all) do
    delete_all
  end
end
