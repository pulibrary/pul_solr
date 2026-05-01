require 'spec_helper'
require 'json'

RSpec.describe 'title sort' do
  include_context 'solr9'

  before { delete_all }

  it 'sorts titles that start with diacritics' do
    solr.add({id: 1, title_sort: 'Falsche Freunde'})
    solr.add({id: 2, title_sort: 'Im Morgenrot '})
    solr.add({id: 3, title_sort: 'Üble Sache Maloney!'})
    solr.commit

    expect(
      solr_response({q: '*', sort: 'title_sort ASC'})['response']['docs']
        .map {|doc| doc['id']}
    ).to eq ['1', '2', '3']
  end

  it 'sorts titles without regard to capitalization' do
    solr.add({id: 4, title_sort: 'Xyz'})
    solr.add({id: 3, title_sort: 'xy'})
    solr.add({id: 2, title_sort: 'abd'})
    solr.add({id: 1, title_sort: 'ABC'})
    solr.commit

    expect(
      solr_response({q: '*', sort: 'title_sort ASC'})['response']['docs']
        .map {|doc| doc['id']}
    ).to eq ['1', '2', '3', '4']
  end

end
