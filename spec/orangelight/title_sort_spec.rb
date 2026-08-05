require 'spec_helper'
require 'json'

RSpec.describe 'title sort' do
  include_context 'solr9'

  before { delete_all }

  it 'sorts titles that start with diacritics' do
    solr.add({id: 1, title_sort_key: 'Falsche Freunde'})
    solr.add({id: 2, title_sort_key: 'Im Morgenrot '})
    solr.add({id: 3, title_sort_key: 'Üble Sache Maloney!'})
    solr.commit

    expect(
      solr_response({q: '*', sort: 'title_sort_key ASC'})['response']['docs']
        .map {|doc| doc['id']}
    ).to eq ['1', '2', '3']
  end

  it 'sorts titles without regard to capitalization' do
    solr.add({id: 4, title_sort_key: 'Xyz'})
    solr.add({id: 3, title_sort_key: 'xy'})
    solr.add({id: 2, title_sort_key: 'abd'})
    solr.add({id: 1, title_sort_key: 'ABC'})
    solr.commit

    expect(
      solr_response({q: '*', sort: 'title_sort_key ASC'})['response']['docs']
        .map {|doc| doc['id']}
    ).to eq ['1', '2', '3', '4']
  end

end
