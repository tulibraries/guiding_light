# Guiding Light: Search LibGuides with Blacklight


## Getting Started

### Ingest LibGuides file into Solr

1. Customize the Solr schema. For Blacklight applications, this file will be `solr/conf/schema.xml`.

    1. Optional: Add the new fields to the `<field>`block with the desired attributes. Those attributes are documented in the `schema.xml` comments.
    2. Add the fields to be searched to...
    3. Add the fields to be shown in the search results index page to...

2. Customize the Solr configuration. For Blacklight applications, this file will be `solr/conf/solrconfig.xml`.

### Install Guiding Light

Guiding light installs as a Ruby Gem:

`gem install guiding_light`

Or add it to your Gemfile:

`gem 'guiding_light'`

### Harvest an individual site

```sh
bundle exec lg2solr import URL_OF_SITE
```

### Harvest complete LibGuide installation given a site map URL

```sh
bundle exec lg2solr harvest http://guides.temple.edu/sitemap.xml
```

### Harvest complete all LibGuides with solr_uri in config file

Use the `config/libguides.yml` to specify the API URL, API key, Solr URI, and ingest batch size and execute the `harvest_all` command to ingest all libguides.

```sh
bundle exec lg2solr harvest_all
```

### LibGuides API Caching

While in development and test, in order to save bandwith and the number of hits to the external LibGuides service, the libguides library caches HTTP calls. Cached files are created on the initial execution and stored in the `cache` directory. Harvesting and Ingest must must run with RAILS_ENV must be either be set to development or test.

```sh
RAILS_ENV=development bundle exec lg2solr harvest_all
```

To clean the cache, delete the contents of the cache files:

```sh
rm -rf cache/*.yml cache/docs/*
```

## Hacking on the gem

`git clone https://github.com/tulibraries/guiding_light`

`cd guiding_light`

`bundle install`

`RUBYLIB=lib RAILS_ENV=development bin/lg2solr harvest_all`

## Running the tests

`rspec`

