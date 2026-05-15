require 'spec_helper'
require 'json'

RSpec.describe 'default fl' do
  include_context 'solr9'

  before { delete_all }

  it 'includes language_iana_s field by default' do
    solr.add({id: 1, language_iana_s: ['ar']})
    solr.commit

    expect(
      solr_response({q: '*'})['response']['docs'].first['language_iana_s']
    ).to eq ['ar']
  end

end
