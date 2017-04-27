require 'spec_helper'
require 'libguides'

describe "LibGuides Module" do
  let (:api_key) { "FAKE API" }
  let (:api_url) { "http://lgapi-us.libapps.com/1.1/guides/" }
  let (:site_id) { 17 }

  describe "LibGuide pages" do
    let (:guide_id) { 120253 }
    it "gets list of pages from the libguide url" do
      pages = Libguides.get_pages(api_url, site_id, guide_id, api_key)
      expect(pages.any? { |p| p['name'] == "Home" }).to be
      expect(pages.any? { |p| p['name'] == "SketchUp" }).to be
      expect(pages.any? { |p| p['name'] == "Beyond SketchUp" }).to be
      expect(pages.any? { |p| p['name'] == "Projects" }).to be
    end
  end

  describe "LibGuides list" do
    it "gets a list of all published libguides" do
      libguides = Libguides.get_guides(api_url, site_id, api_key)

      expect(libguides.any? { |lg| lg['status'] == "1" }).to be
      expect(libguides.any? { |lg| lg['status'] == "0" }).to_not be
      expect(libguides.any? { |lg| lg['status'] == "2" }).to_not be
    end
  end
end
