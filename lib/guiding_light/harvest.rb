require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'rsolr'
require 'securerandom'
require 'ruby-progressbar'
require 'logger'
require 'yaml'
require 'pry'

module GuidingLight::Harvest
  def self.doc_to_solr(libguide_uri, doc_id = libguide_uri, libguide_info = {})
    # Extract metadata and content
    libguide_doc = Nokogiri::HTML(GuidingLight::Request.get_doc(libguide_uri, :File, "cache/docs"))
    libguide_body = libguide_doc.css("#s-lg-guide-main").inner_text.gsub(/\t/, '').gsub(/\n/, '').gsub(/\r/,'').gsub(/\W+/, ' ')
    meta = libguide_doc.css("meta").map { |val| [val["name"], val["content"]] if val.key?("name") }.compact.to_h

    # Assemble solr doc
    solr_doc = Hash.new
    solr_doc["id"] = doc_id
    solr_doc["title_display"] = meta["DC.Title"] if meta.key?("DC.Title")
    solr_doc["title_t"] = meta["DC.Title"] if meta.key?("DC.Title")
    solr_doc["author_display"] = meta["DC.Creator"] if meta.key?("DC.Creator")
    solr_doc["author_facet"] = meta["DC.Creator"] if meta.key?("DC.Creator")
    solr_doc["author_t"] = meta["DC.Creator"] if meta.key?("DC.Creator")
    solr_doc["description_display"] = meta["DC.Description"] if meta.key?("DC.Description")
    solr_doc["description_t"] = meta["DC.Description"] if meta.key?("DC.Description")
    solr_doc["subject_topic_facet"] = meta["DC.Subject"].split(',').map { |i| i.strip } if meta.key?("DC.Subject")
    solr_doc["subject_t"] = meta["DC.Subject"].split(',').map { |i| i.strip } if meta.key?("DC.Subject")
    solr_doc["language_facet"] = meta["DC.Language"] if meta.key?("DC.Language")
    solr_doc["link_facet"] = []
    solr_doc = application_fields(solr_doc, libguide_doc, libguide_info)
    solr_doc["url_fulltext_display"] = libguide_uri
    solr_doc["text"] = libguide_body
    solr_doc
  end

  def self.application_fields(solr_doc, libguide_doc, libguide_info)
    solr_doc
  end

  def self.harvest_all
    config = GuidingLight.configuration
    log = Logger.new("log/harvest_libguides.log")
    #
    # Harvest guides
    #
    solr = RSolr.connect url: config.solr_url
    puts "Using Solr url #{config.solr_url}"
    pages = []
    libguides_sites = get_published(GuidingLight::Request.get_guides(config.api_url, config.site_id, config.api_key))
    # Extract each libguide's page
    pages = libguides_sites.map { |lg|
      # Insert LibGuides response into each page
      metadata = lg.dup
      metadata.delete("pages")
      lg["pages"].each do |p|
        p["libguide_info"] = metadata
      end
      lg['pages']
    }.flatten
    #
    # Ingest guides
    #
    progressbar = ProgressBar.create(:title => "Ingest", :total => pages.count, format: "%t (%c/%C) %a |%B|")
    batch_thread = []
    pages.each_slice(config.solr_batch_size) do |batch|
      batch_thread << Thread.new {
      page_batch = []
      batch.each do |p|
        begin
          page_batch << doc_to_solr(p['url'], p['id'], p['libguide_info'])
        rescue Exception => e
          log.error "Ingest page failed: #{e.message}"
        end
        progressbar.increment
      end
      solr.add page_batch, add_attributes: { commitWithin: 10 }
      }
    end
    solr.commit
    batch_thread.each { |t| t.join }
  end

  def self.cull
    config = GuidingLight.configuration
    log = Logger.new("log/harvest_libguides.log")
    solr = RSolr.connect url: config.solr_url
    libguide_sites = get_unpublished(GuidingLight::Request.get_guides(config.api_url, config.site_id, config.api_key))

    progressbar = ProgressBar.create(:title => "Cull", :total => libguide_sites.count, format: "%t (%c/%C) %a |%B|")
    page_ids = libguide_sites.map do|lg|
      pages = lg['pages'].map { |p| p['id'] }
      response = solr.delete_by_id pages
      progressbar.increment
    end
    solr.commit
  end

  def self.get_published(sites)
    sites.select { |s| s['status'] == '1' }
  end

  def self.get_unpublished(sites)
    sites.select { |s| s['status'] != '1' }
  end
end
