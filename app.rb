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

require_relative 'lib/helpers'
require_relative 'lib/models'
require_relative 'lib/events'
require_relative 'lib/slash_commands'
require_relative 'lib/actions'
