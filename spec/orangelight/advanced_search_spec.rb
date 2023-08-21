require 'spec_helper'
require 'json'

describe 'subject keyword search' do
  include_context 'solr_helpers'
  
  before do
    delete_all
    add_doc("212556")
    add_doc("454035")
    add_doc("1225885")
    solr.commit
  end

  describe 'advanced search dsl query' do
    let(:response) { solr_resp_doc_ids_only(params)['response'] }
    let(:docs) { response['docs'] }
    let(:params) do
      { data:
        {
        "query":
          {"bool":
            {"must":[
              # {"edismax":{"spellcheck.dictionary":"title","qf":"$title_qf","pf":"$title_pf","query":"Theory of the avant-garde"}},
              {"edismax":{"spellcheck.dictionary":"author","qf":"author_display","pf":"author_display","query":"Schumpeter"}}
            ]}
          }
        }
      }
    end
    it 'returns one document that matches the boolean query' do
      expect(response["docs"]).to eq([{ "id" => "212556" }])
    end
  end
end