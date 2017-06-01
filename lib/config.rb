require 'yaml'

module GuidingLight
  class << self
    attr_accessor :configuration
  end

  def self.configure()
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end

  class Configuration
    attr_accessor :api_key, :api_url, :site_id, :solr_url

    def initialize
      begin
        # load Gem config file if it exists
        config = YAML.load_file(File.expand_path "config/libguides.yml")
      rescue
        config = {}
      end
      @api_key  = config.fetch 'api_key',  "DUMMY_API_KEY"
      @api_url  = config.fetch 'api_url',  'http://lgapi-us.libapps.com/1.1/guides/'
      @site_id  = config.fetch 'site_id',  "42"
      @solr_url = config.fetch 'solr_url', "http://localhost:8983/solr/blacklight-core"
    end


  end
end
