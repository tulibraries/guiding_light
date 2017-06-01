require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'rsolr'
require 'securerandom'
require 'ruby-progressbar'
require 'logger'
require 'yaml'
require 'libguides'
require 'analyze_libguides'

module HarvestLibguides

  def self.doc_to_solr(libguide_uri, doc_id = libguide_uri)
    # Extract metadata and content
    libguide_doc = Nokogiri::HTML(Libguides.get_doc(libguide_uri, "cache/docs"))
    libguide_body = libguide_doc.css("#s-lg-guide-main").inner_text.gsub(/\t/, '').gsub(/\n/, '').gsub(/\r/,'').gsub(/\W+/, ' ')
    meta = libguide_doc.css("meta").map { |val| [val["name"], val["content"]] if val.key?("name") }.compact.to_h

    libguide = LibguideDoc.new(libguide_uri, doc_id, meta)
    solr_doc = libguide.to_solr
    solr_doc = libguide.add_fields(solr_doc, libguide_doc)
  end

  def self.import(libguide_uri,
                  solr_endpoint = 'http://localhost:8983/solr/blacklight-core' )
    solr = RSolr.connect url: solr_endpoint
    solr_doc = doc_to_solr(libguide_uri)
    solr.add solr_doc, add_attributes: { commitWithin: 10 }
    solr.commit
  end

  def self.harvest(libguides_sitemap,
              solr_endpoint = 'http://localhost:8983/solr/blacklight-core' )
    sites_doc = Nokogiri::XML(open(libguides_sitemap))
    libguides_sites = sites_doc.xpath('//xmlns:loc').map { |url| url.text }
    batch_size = 10
    batch_thread = []

    puts "Harvesting #{libguides_sitemap}"
    progressbar = ProgressBar.create(:title => "Harvest ", :total => 1 + (libguides_sites.count / batch_size), format: "%t (%c/%C) %a |%B|")
    solr = RSolr.connect url: solr_endpoint
    libguides_sites.each_slice(batch_size) do |batch|
      batch_thread << Thread.new {
        document_batch = []
        batch.each do |item|
          document_batch << ( doc_to_solr(item) )
        end
        solr.add document_batch, add_attributes: { commitWithin: 10 }
        progressbar.increment
      }

      solr.commit

      batch_thread.each { |t| t.join }
    end
  end

  def self.harvest_all
    config = YAML.load_file(File.expand_path "config/libguides.yml")
    log = Logger.new("log/harvest_libguides.log")
    skip_list = Moneta.new(:YAML, file: 'config/skip.yml')
    #
    # Harvest guides
    #
    solr = RSolr.connect url: config['solr_uri']
    pages = []
    libguides_sites = Libguides.get_guides(config['api_url'], config['site_id'], config['api_key'])
    progressbar = ProgressBar.create(:title => "Harvest ", :total => libguides_sites.count, format: "%t (%c/%C) %a |%B|")
    libguides_sites.each do |lg|
      begin
        pages += Libguides.get_pages(config['api_url'], config['site_id'], lg['id'], config['api_key']) unless skip_list["libguide:#{lg['id']}"]
      rescue Exception => e
        log.error "Ingest site failed: #{e.message}"
        skip_list["libguide:#{lg['id']}"] = e.message
      end
      progressbar.increment
    end
    #
    # Ingest guides
    #
    progressbar = ProgressBar.create(:title => "Ingest", :total => pages.count, format: "%t (%c/%C) %a |%B|")
    batch_thread = []
    pages.each_slice(config['solr_batch_size']) do |batch|
      batch_thread << Thread.new {
      page_batch = []
      batch.each do |p|
        begin
          page_batch << doc_to_solr(p['url'], p['id']) unless skip_list["#{p['url']}"]
        rescue Exception => e
          log.error "Ingest page failed: #{e.message}"
          skip_list["#{p['url']}"] = e.message
        end
        progressbar.increment
      end
      solr.add page_batch, add_attributes: { commitWithin: 10 }
      }
    end
    solr.commit
    batch_thread.each { |t| t.join }
  end
  puts

end

class SolrDoc
  attr_reader :doc, :libguide_uri, :doc_id, :title, :author, :description, :subjects, :language, :url, :text, :links

  def initialize(libguide_uri, doc_id, meta = {})
    @libguide_uri = libguide_uri
    @id = doc_id.to_s
    @title = meta["DC.Title"]
    @author = meta["DC.Creator"]
    @description = meta["DC.Description"]
    @subject = meta["DC.Subject"].split(',').map { |i| i.strip } if meta.key?("DC.Subject")
    @language = meta["DC.Language"]
    @url = meta["url"]
    @text = meta["text"]
  end

  def to_solr
    doc = {    
      "id" => @id,
      "title_display" => @title,
      "title_t" => @title,
      "author_display" => @author,
      "author_facet" => @author,
      "author_t" => @author,
      "description_display" => @description,
      "description_t" => @description,
      "subject_topic_facet" => @subject,
      "subject_t" => @subject,
      "language_facet" => @language,
      "url_fulltext_display" => @libguide_uri,
      "text" => @text,
    }
  end
end

class LibguideDoc < SolrDoc
  def add_fields(solr_doc, libguide_doc)
    solr_doc["link_facet"] = []
    external_link_patterns.each do |type, shortname, pattern|
      link_count =  AnalyzeLibguides.link_count(pattern, libguide_doc)
      solr_doc["link_facet"] << "Has #{type} links" if  link_count > 0
      solr_doc["#{shortname}_links_count_i"] = link_count
    end
    solr_doc
  end

  def external_link_patterns
    [
      ["Summon", 'summon', /temple.summon.serialssolutions.com/],
      ["Diamond Permanent", 'diamond', /diamond.temple.edu\/record=/],
      ["Diamond Non-Permanent", 'diamond_other', /diamond.temple.edu\/(?!record=)/],
      ["Journal Finder", 'journal_finder', /vv4kg5gr5v.search.serialssolutions.com/]
    ]
  end
end
