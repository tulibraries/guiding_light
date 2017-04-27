require 'harvest_libguides'

namespace :blimp do
  namespace :libguides do
    desc "Ingest a sitemap"
    task :ingest, [:source] do |t, args|
      Rake::FileList.new("*.csv") do |fl|
        fl.each { |f| HarvestLibGuides.harvest(f) }
      end
    end
  end
end
