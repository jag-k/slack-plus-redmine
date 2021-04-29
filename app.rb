# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

Bundler.require :default

Dir[File.expand_path('config/initializers', __dir__) + '/**/*.rb'].sort.each do |file|
  require file
end

ActiveRecord::Base.establish_connection(
  YAML.safe_load(
    ERB.new(
      File.read('config/database.yml')
    ).result, [], [], true
  )[ENV['RACK_ENV']]
)

Dir[File.expand_path('lib', __dir__) + '/**/*.rb'].sort.each do |file|
  require file
end
