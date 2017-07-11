require 'rails'
require 'guiding_light'

module GuidingLight
  class Railtie < Rails::Railtie
    railtie_name :guiding_light

    rake_tasks do
      load 'tasks/guiding_light.rake'
    end
  end
end
