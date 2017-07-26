require 'spec_helper'
require 'securerandom'
require 'guiding_light'

describe "Libguides::Harvest" do
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
    it "converts a valid solr document" do
      doc_uri = File.join(File.expand_path(RSpec.configuration.fixtures_path), "test.xml")
      expected_document = {"id" => doc_uri,
                           "body_t" => ["In the middle of the earth in the land of Shire",
                           "Lives a brave little hobbit whom we all admire",
                           "With his long wooden pipe fuzzy woolly toes",
                           "He lives in a hobbit hole and everybody knows him"].join(' ')}
      actual_document = GuidingLight::Harvest.doc_to_solr(doc_uri.to_s)
      expect(actual_document["id"]).to match /#{expected_document["id"]}/
      expect(actual_document["text"]).to match /#{expected_document["body_t"]}/
    end

  end

  describe "To Solr core" do
    xit "ingests LibGuides into Solr-core" do
      solr_uri = 'http://localhost:8983/solr/blacklight-core'
      libguides_sitemap = "http://guides.temple.edu/sitemap.xml"
      GuidingLight::Harvest.harvest(libguides_sitemap, solr_uri)
    end
  end

  describe "All Published LibGuides" do
    let (:api_key) { "FAKE_API_KEY" }
    let (:api_url) { "http://lgapi-us.libapps.com/1.1/guides/" }
    let (:site_id) { 42 }
    let (:solr_uri) { 'http://localhost:8983/solr/blacklight-core' }

    xit "ingests all publsihed LibGuides with expanded pages into Solr-Core" do
      libguides = GuidingLight.get_guides(api_url, site_id, api_key)

    end
  end
end
