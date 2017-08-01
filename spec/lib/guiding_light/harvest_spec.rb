require 'spec_helper'
require 'securerandom'
require 'guiding_light'

describe "GuidingLight::Harvest" do
  let (:spec_api_key) { "SPEC_API_KEY" }
  let (:spec_api_url) { 'http://lgapi-us.example.com/1.1/guides/b' }
  let (:spec_site_id) { "42" }
  let (:spec_solr_url) { "http://localhost:8983/solr/blacklight-core" }

  before do
    GuidingLight::Configuration.new
    GuidingLight.configure do |config|
      config.api_key = spec_api_key
      config.api_url = spec_api_url
      config.site_id = spec_site_id
      config.solr_url = spec_solr_url
    end
  end

  describe "convert LibGuide document to Solr document" do
    let (:doc_uri ) { File.join(File.expand_path(RSpec.configuration.fixtures_path), "test.xml") }
    let (:expected_document) {
      {
        "id" => doc_uri,
        "text" => ["In the middle of the earth in the land of Shire",
        "Lives a brave little hobbit whom we all admire",
        "With his long wooden pipe fuzzy woolly toes",
        "He lives in a hobbit hole and everybody knows him"].join(' ')
      }
    }
    let (:metadata) {
      {
        "id"=>"312",
        "type_id"=>"4",
        "site_id"=>"17",
        "owner_id"=>"213",
        "group_id"=>"139",
        "name"=>"Statistics-Health",
        "description"=>"",
        "redirect_url"=>"",
        "status"=>"1",
        "published"=>"2014-05-09 19:52:51",
        "created"=>"2014-02-25 16:42:30",
        "updated"=>"2017-06-27 15:24:54",
        "slug_id"=>"1049303",
        "friendly_url"=>"http://guides.temple.edu/healthstatistics",
        "nav_type"=>"1",
        "count_hit"=>"159",
        "url"=>"http://guides.temple.edu/c.php?g=312",
        "status_label"=>"Published",
        "type_label"=>"Topic Guide"
      }
    }

    let (:solr_doc) { {
      "id" => doc_uri,
      "body_t" => ["In the middle of the earth in the land of Shire",
      "Lives a brave little hobbit whom we all admire",
      "With his long wooden pipe fuzzy woolly toes",
      "He lives in a hobbit hole and everybody knows him"].join(' ')
    } }
    
    it "converts a valid solr document" do
      doc_uri = File.join(File.expand_path(RSpec.configuration.fixtures_path), "test.xml")
      expected_document = solr_doc
      actual_document = GuidingLight::Harvest.doc_to_solr(doc_uri.to_s)
      expect(actual_document["id"]).to match /#{expected_document["id"]}/
      expect(actual_document["text"]).to match /#{expected_document["text"]}/
    end
    
    it "has libguide specific information" do
      allow(::GuidingLight::Harvest).to receive(:application_fields).with(any_args) { 
        solr_doc.tap { |doc| doc["publishing_status"] = metadata["status_label"] }
      } 
      actual_document = GuidingLight::Harvest.doc_to_solr(doc_uri.to_s, doc_uri.to_s, metadata)
      expect(actual_document["publishing_status"]).to match /#{metadata["status_label"]}/
    end
  end

  it "removes libguides that have become unpublished"
  it "removes libguides that have become priviate"
end
