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
      @api_key  = "DUMMY_API_KEY"
      @api_url  = 'http://lgapi-us.libapps.com/1.1/guides/'
      @site_id  = "42"
      @solr_url = "http://localhost:8983/solr/blacklight-core"
    end

  end
end
