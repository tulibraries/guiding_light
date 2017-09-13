# Guiding Light: Search LibGuides with Blacklight

Guiding Light is a Ruby powered tool used to ingest LibGuides into [Solr](Guiding Light is a Ruby powered tool used to ingest LibGuides into Solr searcable in a [Project Blacklight](https://projectblacklight.org) web application
searchable from a [Project Blacklight](https://projectblacklight.org) web application.

## Set Up

Guiding Light will need to know:

- LibGuides API Key
- LibGuides URL
- LibGuides Site ID
- Solr URL entry point

## Installation

### Install Guiding Light

There are two ways to install Guiding Light

Guiding Light installs as a Ruby Gem:

`gem install guiding_light`

Or add it to your Gemfile:

`gem 'guiding_light'`

Then from the command line, install Guiding Light:

`bundle install`

OR -- Do it in one step

`rails new app -m https://raw.githubusercontent.com/tulibraries/guiding_light/master/template.rb`

### Configure Guiding Light

Create a Guiding Light configuration file in your Blacklight application project
directory `config/guiding_light.yml` as shown below.  Modify with the LibGuide's
API key, URL, and Site ID, and the Blacklight application's Solr entry point
URL. For best performance, `solr_batch_size` should be kept at 100.

```yaml
default: &default
  api_key:  "Your-LibGuides-API-Key"
  api_url:  "http://lgapi-us.libapps.com/1.1/guides/"
  site_id:  "123"
  solr_url: "http://localhost:8983/solr/blacklight-core"
  solr_batch_size: 100

development:
    <<: *default

test:
    <<: *default

production:
    <<: *default
```

## Usage

- Harvest and ingest LibGuides into Solr
```sh
bundle exec rake guiding_light:harvest_all
```

- Delete *all* Libguides in Solr
```sh
bundle exec rake guiding_light:delete_all
```

- Commit all *pending* added and deleted documents
```sh
bundle exec rake guiding_light:commit
```

## Customization

To add custom Solr fields, create a Ruby file `config/initializers/override/guiding_light_local.rb` in your Blacklight installation
and override the `GuidingLight::Harvest.application_fields` class method. Example:

```ruby
require 'guiding_light/harvest'

GuidingLight::Harvest.module_eval do
  def self.application_fields(solr_doc, libguide_doc)
    external_link_patterns.each do |type,shortname, pattern|
      link_count = libguide_doc.xpath("//a").map { |a| a["href"] }.select { |link| link =~ pattern }.count
      solr_doc["link_facet"] << "Has #{type} links" if  link_count > 0
      solr_doc["#{shortname}_links_count_i"] = link_count
    end
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
end
```

### LibGuides API Caching

In order to minimize API bandwith and the number of hits to the external LibGuides service while
developing or testing, Guiding Light caches HTTP calls. Cached files are created on the initial
execution and stored in the `cache` directory. Harvesting and Ingest must must run with `RAILS_ENV`
must be either be set to `development` or `test`.

```sh
RAILS_ENV=development bundle exec lg2solr harvest_all
```

To clean the cache, delete the cache files:

```sh
rm -rf cache/*.yml cache/docs/*
```

## Hacking on the gem

`git clone https://github.com/tulibraries/guiding_light`

`cd guiding_light`

`bundle install`

`RUBYLIB=lib RAILS_ENV=development bin/lg2solr harvest_all`

## Testing

To run tests, Solr must be running.  In a separate shell:

```
bundle exec solr_wrapper
```

Execute the [RSpec](http://rspec.info) tests

```sh
bundle exec rspec spec
```
