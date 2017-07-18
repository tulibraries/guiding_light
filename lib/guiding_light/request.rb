require 'rubygems'
require 'json'
require 'open-uri'
require 'moneta'
require 'digest'

module GuidingLight::Request

  def self.use_caching?
    return ["development", "test"].include? ENV["RAILS_ENV"]
  end

  def self.get_doc(url, cache_type=:File, cache_path="moneta")
    if use_caching?
      if cache_type == :YAML
        cache = Moneta.new(cache_type, file: cache_path)
        doc = cache.fetch(url) { cache[url] = open(url).read }
      else
        cache = Moneta.new(cache_type, dir: cache_path)
        url_hash = Digest::MD5.hexdigest(url)
        doc = cache.fetch(url_hash) { cache[url_hash] = open(url).read }
      end
    else
      doc = open(url).read
    end
  end

  def self.get_guides(api_url, site_id, api_key)
    url = "#{api_url}?site_id=#{site_id}?&key=#{api_key}&expand=pages"
    sites = JSON.parse(get_doc(url, :YAML, "cache/guides.yml"))
    published_sites = sites.select { |s| s['status'] == '1' }
  end
end
