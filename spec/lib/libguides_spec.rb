require 'spec_helper'
require 'guiding_light'

describe "GuidingLights Module" do
  let (:api_key) { "FAKE API" }
  let (:api_url) { "http://lgapi-us.libapps.com/1.1/guides/" }
  let (:site_id) { 17 }

  describe "GuidingLight pages" do
    let (:guide_id) { 120253 }
    it "gets list of pages from the GuidingLight url" do
      allow(allow(OpenURI).to receive(:open).and_return(hdoc = StringIO.new)).to receive(:read) { "TEST" }
      pages = GuidingLights.get_pages(api_url, site_id, guide_id, api_key)
      expect(pages.any? { |p| p['name'] == "Home" }).to be
      expect(pages.any? { |p| p['name'] == "SketchUp" }).to be
      expect(pages.any? { |p| p['name'] == "Beyond SketchUp" }).to be
      expect(pages.any? { |p| p['name'] == "Projects" }).to be
    end
  end

  describe "GuidingLights list" do
    it "gets a list of all published GuidingLights" do
      allow(allow(OpenURI).to receive(:open).and_return(hdoc = StringIO.new)).to receive(:read) { "TEST" }
      GuidingLights = GuidingLights.get_guides(api_url, site_id, api_key)

      expect(GuidingLights.any? { |lg| lg['status'] == "1" }).to be
      expect(GuidingLights.any? { |lg| lg['status'] == "0" }).to_not be
      expect(GuidingLights.any? { |lg| lg['status'] == "2" }).to_not be
    end
  end
end
