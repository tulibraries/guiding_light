require 'spec_helper'
require 'securerandom'
require 'harvest_libguides'
require 'libguides'

describe "convert LibGuide document to Solr document" do
  it "converts a valid solr document" do
    doc_uri = File.join(File.expand_path(RSpec.configuration.fixtures_path), "test.xml")
    expected_document = {"id" => doc_uri,
                         "body_t" => ["In the middle of the earth in the land of Shire",
                         "Lives a brave little hobbit whom we all admire",
                         "With his long wooden pipe fuzzy woolly toes",
                         "He lives in a hobbit hole and everybody knows him"].join(' ')}
    lgdoc = LibguidesDoc.new
    actual_document = lgdoc.doc_to_solr(doc_uri.to_s)
    expect(actual_document["id"]).to match /#{expected_document["id"]}/
    expect(actual_document["text"]).to match /#{expected_document["body_t"]}/
  end

end

describe "To Solr core" do
  xit "ingests LibGuides into Solr-core" do
    solr_uri = 'http://localhost:8983/solr/blacklight-core'
    libguides_sitemap = "http://guides.temple.edu/sitemap.xml"
    HarvestLibguides.harvest(libguides_sitemap, solr_uri)
  end
end

describe "All Published LibGuides" do
  let (:api_key) { "FAKE_API_KEY" }
  let (:api_url) { "http://lgapi-us.libapps.com/1.1/guides/" }
  let (:site_id) { 42 }
  let (:solr_uri) { 'http://localhost:8983/solr/blacklight-core' }

  xit "ingests all publsihed LibGuides with expanded pages into Solr-Core" do
    libguides = Libguides.get_guides(api_url, site_id, api_key)

  end
end
