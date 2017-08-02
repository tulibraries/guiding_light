FactoryGirl.define do
  factory :solr_document, class: Hash do
    "id" doc_uri
    "text" ["In the middle of the earth in the land of Shire"
    "Lives a brave little hobbit whom we all admire"
    "With his long wooden pipe fuzzy woolly toes"
    "He lives in a hobbit hole and everybody knows him"].join(' ')
  end

  factory :published_libguide, class: Hash do
    "id" "312"
    "type_id" "4"
    "site_id" "17"
    "owner_id" "213"
    "group_id" "139"
    "name" "Statistics-Health"
    "description" ""
    "redirect_url" ""
    "status" "1"
    "published" "2014-05-09 19:52:51"
    "created" "2014-02-25 16:42:30"
    "updated" "2017-06-27 15:24:54"
    "slug_id" "1049303"
    "friendly_url" "http://guides.temple.edu/healthstatistics"
    "nav_type" "1"
    "count_hit" "159"
    "url" "http://guides.temple.edu/c.php?g=312"
    "status_label" "Published"
    "type_label" "Topic Guide"
  end
end
