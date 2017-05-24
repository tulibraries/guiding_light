# Guiding Light: Search LibGuides with Blacklight


## Getting Started

## Hacking on the gem


`git clone https://github.com/tulibraries/guiding_light`

`cd guiding_light`

`bundle install`

:hammer: :computer: :nut_and_bolt: :computer: :hammer:



## Running the tests

`rspec`


Rake file to ingest LibGuides file data into Solr. Presumes the LibGuides file has unique headers

## Ingest LibGuides file into Solr

1. Customize the Solr schema. For Blacklight applications, this file will be `solr/conf/schema.xml`.

    1. Optional: Add the new fields to the `<field>`block with the desired attributes. Those attributes are documented in the `schema.xml` comments.
    2. Add the fields to be searched to...
    3. Add the fields to be shown in the search results index page to...

2. Customize the Solr configuration. For Blacklight applications, this file will be `solr/conf/solrconfig.xml`.

## Harvest an individual site

```sh
ruby bin/libguides2solr.rb import URL_OF_SITE
```

## Harvest complete LibGuide installation given a site map URL

```sh
ruby bin/libguides2solr.rb harvest http://guides.temple.edu/sitemap.xml
```


