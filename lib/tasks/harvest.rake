require 'harvest_libguides'

namespace :guidinglight do
  desc 'harvests all libguides associated with API URL in `config/libguides.yaml`'
  task :harvest_all do
    Libguides::Harvest.harvest_all
  end
end
