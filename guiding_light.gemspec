$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "guiding_light/version"

Gem::Specification.new do |s|
  s.name = 'guiding_light'
  s.version = GuidingLight::VERSION
  s.executables << 'lg2solr'
  s.authors = ["Steven Ng", "Chad Nelson"]
  s.date = %q{2017-05-30}
  s.description = "Guiding Light - Ingests LibGuides site into Solr"
  s.summary = "Import LibGuides into Solr"
  s.email = "steven.ng@temple.edu"
  s.files = `git ls-files`.split("\n")
  s.bindir = "bin"
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']
  s.homepage = 'https://github.com/tulibraries/guiding_light'

  s.add_runtime_dependency 'rsolr', '~> 1.0'
  s.add_runtime_dependency 'ruby-progressbar', '~> 1.8' 
  s.add_runtime_dependency 'activesupport', '~> 5.0'
  s.add_runtime_dependency 'rack-utf8_sanitizer', '~> 1.3'
  s.add_runtime_dependency 'nokogiri', '~> 1.7'
  s.add_runtime_dependency 'thor', '~> 0.19'
  s.add_runtime_dependency 'moneta', '~> 1.0'
  s.add_runtime_dependency 'rake'

  s.add_development_dependency 'bundler', '~> 1.13'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'solr_wrapper'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'coveralls'
end
