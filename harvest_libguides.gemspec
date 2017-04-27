$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "version"

Gem::Specification.new do |s|
  s.name = 'harvest_libguides'
  s.version = HarvestLibguides::VERSION
  s.executables << 'lg2solr'
  s.authors = ["Steven Ng"]
  s.date = %q{2017-04-12}
  s.description = "Harvest LibGuides - Ingests LibGuides site into Solr"
  s.summary = "Import LibGuides into Solr"
  s.email = "steven.ng@temple.edu"
  s.files = `git ls-files`.split("\n")
  s.bindir = "bin"
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']
  s.homepage = 'https://github.com/tulibraries/harvest_libguides'

  s.add_runtime_dependency 'rsolr', '~> 1.0'
  s.add_runtime_dependency 'ruby-progressbar', '~> 1.8' 
  s.add_runtime_dependency 'activesupport', '~> 5.0'
end
