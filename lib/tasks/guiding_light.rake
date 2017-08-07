namespace :guiding_light do

  desc 'Harvest All Collections'
  task :harvest_all do
    #Check if we are in Rails, if so call with environment dependency
    if Rake::Task.task_defined?("environment")
      Rake::Task["guiding_light:harvest_all_rails"].invoke
    else
      Rake::Task["guiding_light:harvest_all_gem"].invoke
    end
  end

  #desc "Task from within a Rails app"
  task :harvest_all_rails => :environment do
    Rake::Task["guiding_light:harvest_all_gem"].invoke
  end

  #desc "Task called from the gem itself"
  task :harvest_all_gem do
    GuidingLight::Harvest.harvest_all
  end

  desc "Delete All Collections"
  task :delete_all do
    GuidingLight::Harvest.delete_all
  end

  desc "Commit Solr Transactions"
  task :commit do
    GuidingLight::Harvest.commit
  end

end
