require 'rubygems'
require 'nokogiri'
require 'pry'

module AnalyzeLibguides 
  def self.has_summon_link(libguide_doc)
    # Extract metadata and content
    summon_pattern = /http:\/\/temple.summon.serialssolutions.com/
    libguide_doc.xpath("//a").map { |a| a["href"] }.select { |link| link =~ summon_pattern }.count > 0
  end
end
