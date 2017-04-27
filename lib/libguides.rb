require 'rubygems'
require 'nokogiri'
require 'json'
require 'open-uri'
require 'byebug'

module Libguides
  def self.get_pages(api_url, site_id, guide_id, api_key)
    # Extract metadata and content
    url = "#{api_url}#{guide_id}?site_id=#{site_id}?&key=#{api_key}&expand=pages"
    doc = Nokogiri::HTML(open(url))
    doc_hash = JSON.parse(doc.css("p").children.first).first
    pages = doc_hash["pages"]
  end

  def self.get_guides(libguide_url, site_id, api_key)
    url = "#{libguide_url}?site_id=#{site_id}&key=#{api_key}"
    doc = Nokogiri::HTML(open(url))
    sites = JSON.parse(doc.css("p").entries.first)
    published_sites = sites.select { |s| s['status'] == '1' }
  end
end
