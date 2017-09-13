# frozen_string_literal: true

gem 'blacklight', github: 'projectblacklight/blacklight'

gem 'guiding_light', github: 'tulibraries/guiding_light'

run 'bundle install'

generate 'blacklight:install', '--devise'

rake 'db:migrate'

gldir = `bundle show guiding_light`.chop
source = "#{gldir}/config/guiding_light.example.yml"
destination = "config/guiding_light.example.yml"
copy_file(source, destination)

readme "POSTINSTALL"
