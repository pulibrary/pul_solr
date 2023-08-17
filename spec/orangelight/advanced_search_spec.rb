require 'spec_helper'
require 'json'

describe 'subject keyword search' do
  include_context 'solr_helpers'
  
  before do
    delete_all
    add_doc("212556")
    add_doc("454035")
    solr.commit
  end

  describe 'advanced search dsl query' do
    let(:response) { solr_resp_doc_ids_only(params, "advanced")['response'] }
    let(:docs) { response['docs'] }
    let(:params) do
      { data:
        {"params":
          {"qt":nil,
            "facet":true,
            "facet.field":["access_facet","location","format","recently_added_facet"],
            "f.access_facet.facet.sort":"index",
            "f.location.facet.sort":"index",
            "f.location.facet.mincount":1,
            "f.location.facet.limit":21,
            "f.format.facet.sort":"index",
            "f.format.facet.mincount":1,
            "f.format.facet.limit":16,
            "f.language_facet.facet.limit":11,
            "f.subject_topic_facet.facet.limit":11,
            "f.genre_facet.facet.limit":11,
            "f.subject_era_facet.facet.limit":11,
            "facet.query":["cataloged_tdt:[NOW/DAY-7DAYS TO NOW/DAY+1DAY]","cataloged_tdt:[NOW/DAY-14DAYS TO NOW/DAY+1DAY]","cataloged_tdt:[NOW/DAY-21DAYS TO NOW/DAY+1DAY]","cataloged_tdt:[NOW/DAY-1MONTH TO NOW/DAY+1DAY]","cataloged_tdt:[NOW/DAY-2MONTHS TO NOW/DAY+1DAY]","cataloged_tdt:[NOW/DAY-3MONTHS TO NOW/DAY+1DAY]","cataloged_tdt:[NOW/DAY-6MONTHS TO NOW/DAY+1DAY]","pub_date_start_sort:[1100 TO 1199]","pub_date_start_sort:[1200 TO 1299]","pub_date_start_sort:[1300 TO 1399]","pub_date_start_sort:[1400 TO 1499]","pub_date_start_sort:[1500 TO 1599]","pub_date_start_sort:[1600 TO 1699]","pub_date_start_sort:[1700 TO 1799]","pub_date_start_sort:[1800 TO 1899]","pub_date_start_sort:[1900 TO 1999]","pub_date_start_sort:[2000 TO 2024]"],
            "f.instrumentation_facet.facet.limit":11,
            "f.publication_place_facet.facet.limit":11,
            "facet.pivot":[],
            "f.sudoc_facet.facet.sort":"index",
            "f.sudoc_facet.facet.limit":11,
            "rows":20,
            "sort":"score desc, pub_date_start_sort desc, title_sort asc",
            "stats":"true",
            "stats.field":["pub_date_start_sort"]},
        "query":
          {"bool":
            {"must":[
              {"edismax":{"spellcheck.dictionary":"title","qf":"${title_qf}","pf":"${title_pf}","query":"Theory of the avant-garde"}},
              {"edismax":{"spellcheck.dictionary":"author","qf":"${author_qf}","pf":"${author_pf}","query":"Bürger"}}
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