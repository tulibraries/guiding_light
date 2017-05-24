require 'rubygems'
require 'nokogiri'

module AnalyzeLibguides 

  def self.link_count(pattern, libguide_doc)
    libguide_doc.xpath("//a").map { |a| a["href"] }.select { |link| link =~ pattern }.count
  end
end
