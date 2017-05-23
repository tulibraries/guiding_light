require 'spec_helper'
require 'analyze_libguides'

describe "Analyze LibGuides for Summon links" do
  it "doesn't have a Summon link" do
    doc_uri = File.join(File.expand_path(RSpec.configuration.fixtures_path), "test.xml")
    doc = Nokogiri::HTML(open(doc_uri))
    expect(AnalyzeLibguides.has_summon_link?(doc)).to_not be
  end
  
  it "has a Summon link" do
    doc_uri = File.join(File.expand_path(RSpec.configuration.fixtures_path), "test_summon_link.xml")
    doc = Nokogiri::HTML(open(doc_uri))
    expect(AnalyzeLibguides.has_summon_link?(doc)).to be
  end
end
