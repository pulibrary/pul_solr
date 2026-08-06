require 'spec_helper'
require 'json'

RSpec.describe 'author sort' do
  include_context 'solr9'

  before { delete_all }

  it 'sorts authors' do
    solr.add({id: 2, author_sort_key: 'Kleinewillinghöfer, Ulrich, 1951-'})
    solr.add({id: 1, author_sort_key: 'Balga, Jean Paul'})
    solr.add({id: 3, author_sort_key: 'Mu\'azu, Mohammed Aminu, 1968-'})
    solr.commit

    expect(
      solr_response({q: '*', sort: 'author_sort_key ASC'})['response']['docs']
        .map {|doc| doc['id']}
    ).to eq ['1', '2', '3']
  end

end
