require 'spec_helper'
require 'guiding_light'

describe "GuidingLight" do
  describe "#configure" do
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

    it "returns an api_key as a string" do
      api_key = GuidingLight.configuration.api_key

      expect(api_key).to be_a(String)
      expect(api_key).to eq(spec_api_key)
    end

    it "returns an api_url as a string" do
      api_url = GuidingLight.configuration.api_url

      expect(api_url).to be_a(String)
      expect(api_url).to eq(spec_api_url)
    end

    it "returns an site_id as a string" do
      site_id = GuidingLight.configuration.site_id

      expect(site_id).to be_a(String)
      expect(site_id).to eq(spec_site_id)
    end

    it "returns an solr_url as a string" do
      solr_url = GuidingLight.configuration.solr_url

      expect(solr_url).to be_a(String)
      expect(solr_url).to eq(spec_solr_url)
    end
  end
end
