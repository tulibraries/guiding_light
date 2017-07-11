namespace :guiding_light do
  desc 'Harvest All Collections'
  task :harvest_all => :environment do
    GuidingLight::Harvest.harvest_all
  end
end
