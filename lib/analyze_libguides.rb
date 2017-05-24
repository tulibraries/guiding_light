require 'rubygems'
require 'nokogiri'

module AnalyzeLibguides 
  def self.has_summon_link?(libguide_doc)
    # Extract metadata and content
    summon_pattern = /http:\/\/temple.summon.serialssolutions.com/
    summon_count = libguide_doc.xpath("//a").map { |a| a["href"] }.select { |link| link =~ summon_pattern }.count
    summon_count > 0
  end
end
