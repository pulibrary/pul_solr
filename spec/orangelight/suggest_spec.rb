require 'spec_helper'

RSpec.describe 'autosuggest' do
  include_context 'solr9'

  before { delete_all }

  describe 'south_asian_latin dictionary' do
    it 'suggests LC Romanization when the user inputs a more intuitive Romanization' do
      lc_terms = [
        'Premacanda',
        'Viśva Hindū Parishad',
        'Babari Masjid',
        'Maṇipura itihāsa',
        'Bijaẏa Pañcāli',
        'Bibhūtibhūshaṇa Bandyopādhyāẏa',
        'Rāmajanmabhūmi',
      ]
      lc_terms.each_with_index { |term, index| solr.add({id: index, south_asian_latin_suggest: [term]}) }
      solr.commit

      intuitive_to_lc = {
        'premchand' => 'Premacanda',
        'Vishwa Hindu Parishad' => 'Viśva Hindū Parishad',
        'Viśva Hindū Parishada' => 'Viśva Hindū Parishad',
        'Manipur Itihas' => 'Maṇipura itihāsa',
        'Bijoy Panchali' => 'Bijaẏa Pañcāli',
        'Babri Masjid' => 'Babari Masjid',
        'Vibhutibhushana Vandyopadhyay' => 'Bibhūtibhūshaṇa Bandyopādhyāẏa',
        'Bibhutibhushan Bandyopadhyay' => 'Bibhūtibhūshaṇa Bandyopādhyāẏa',
        'Bibhutibhushan Banerji' => 'Bibhūtibhūshaṇa Bandyopādhyāẏa',
        'Ram janmabhoomi' => 'Rāmajanmabhūmi',
      }

      intuitive_to_lc.each do |intuitive, lc|
        results = solr_response(
          {'suggest.q': intuitive, 'suggest.dictionary': 'south_asian_latin'},
          'suggest'
        )['suggest']['south_asian_latin'][intuitive]

        expect(results['numFound']).to eq(1),
          "expected to get 1 suggestion for #{intuitive} but there were #{results['numFound']}"
        expect(results['suggestions'].map { it['term'] }).to eq([lc]),
          "expected suggestions for #{intuitive} to include #{lc}"
      end
    end
  end
end
