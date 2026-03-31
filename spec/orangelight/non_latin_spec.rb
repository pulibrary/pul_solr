require 'spec_helper'

RSpec.describe 'non-latin non-cjk fields' do
    include_context 'solr9'

    describe 'non_latin_non_cjk_all_index' do
      after(:all) { delete_all }
      it 'is searchable in Arabic' do
        solr.add({ id: 1, non_latin_non_cjk_all_index: 'حبار' })
        solr.add({ id: 2, non_latin_non_cjk_all_index: 'دُلفين' })
        solr.commit

        results = solr_resp_doc_ids_only({q: 'حبار'})
        expect(results['response']['docs']).to eq [{'id' => '1'}]
      end
    end

    describe 'non_latin_non_cjk_title_index' do
      after(:all) { delete_all }
      it 'is searchable in Arabic' do
        solr.add({ id: 1, non_latin_non_cjk_title_index: 'حبار' })
        solr.add({ id: 2, non_latin_non_cjk_title_index: 'دُلفين' })
        solr.commit

        results = solr_resp_doc_ids_only({q: 'حبار'})
        expect(results['response']['docs']).to eq [{'id' => '1'}]
      end
    end
end

