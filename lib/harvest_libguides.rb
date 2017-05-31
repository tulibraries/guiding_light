require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'rsolr'
require 'byebug'
require 'securerandom'
require 'ruby-progressbar'
require 'logger'
require 'yaml'
require 'libguides'

module HarvestLibguides
  def self.doc_to_solr(libguide_uri, doc_id = libguide_uri)
    # Extract metadata and content
    libguide_doc = Nokogiri::HTML(Libguides.get_doc(libguide_uri, :File, "cache/docs"))
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
    external_link_patterns.each do |type,shortname, pattern|
      link_count =  AnalyzeLibguides.link_count(pattern, libguide_doc)
      solr_doc["link_facet"] << "Has #{type} links" if  link_count > 0
      solr_doc["#{shortname}_links_count_i"] = link_count
    end
    solr_doc["url_fulltext_display"] = libguide_uri
    solr_doc["text"] = libguide_body
    solr_doc
  end

  def self.external_link_patterns
    [
      ["Summon", 'summon', /temple.summon.serialssolutions.com/],
      ["Diamond Permanent", 'diamond', /diamond.temple.edu\/record=/],
      ["Diamond Non-Permanent", 'diamond_other', /diamond.temple.edu\/(?!record=)/],
      ["Journal Finder", 'journal_finder', /vv4kg5gr5v.search.serialssolutions.com/]
    ]
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

      puts "Awaiting completion"
      batch_thread.each { |t| t.join }
      puts "Done"
    end
  end

  def self.harvest_single(libguides_sitemap,
                   solr_endpoint = 'http://localhost:8983/solr/blacklight-core' )
    sites_doc = Nokogiri::XML(open(libguides_sitemap))
    libguides_sites = sites_doc.xpath('//xmlns:loc').map { |url| url.text }

    progressbar = ProgressBar.create(:title => "Harvest ", :total => 1 + (libguides_sites.count), format: "%t (%c/%C) %a |%B|")
    libguides_sites.each do |site|
      import(site, solr_endpoint)
      progressbar.increment
    end
  end

  def self.harvest_all
    config = YAML.load_file(File.expand_path "config/libguides.yml")
    log = Logger.new("log/harvest_libguides.log")
    #
    # Harvest guides
    #
    solr = RSolr.connect url: config['solr_uri']
    pages = []
    libguides_sites = Libguides.get_guides(config['api_url'], config['site_id'], config['api_key'])
    progressbar = ProgressBar.create(:title => "Harvest ", :total => libguides_sites.count, format: "%t (%c/%C) %a |%B|")
    libguides_sites.each do |lg|
      begin
        pages += Libguides.get_pages(config['api_url'], config['site_id'], lg['id'], config['api_key'])
      rescue Exception => e
        log.error "Ingest site failed: #{e.message}"
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
          page_batch << doc_to_solr(p['url'], p['id'])
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
  puts

end
