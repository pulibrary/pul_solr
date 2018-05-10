require 'spec_helper'
require 'json'

describe 'subject keyword search' do
  include_context 'solr_helpers'

  def subject_query_string(q)
    "{!qf=$subject_qf pf=$subject_pf}#{q}"
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
      expect(solr_resp_doc_ids_only('q' => subject_query_string('ʻUthmān, ʻUthmān'))).to include(diacritic_subject)
    end
    it 'retrieves book when diacritics excluded' do
      expect(solr_resp_doc_ids_only('q' => subject_query_string('Uthman'))).to include(diacritic_subject)
    end
  end
  describe 'stopwords' do
    stop_word_subject = '1332805'
    before(:all) do
      add_doc(stop_word_subject)
    end
    it 'retrieves book when stop words included' do
      expect(solr_resp_doc_ids_only('q' => subject_query_string('image of god'))).to include(stop_word_subject)
    end
    it 'retrieves book when stop words excluded' do
      expect(solr_resp_doc_ids_only('q' => subject_query_string('image god'))).to include(stop_word_subject)
    end
  end
  after(:all) do
    delete_all
  end
end
