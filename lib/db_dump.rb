require 'rubygems'
require 'yaml'
require 'active_record'
require 'rails/railtie'
require 'db_dump/rake_tasks'
require 'db_dump/version'
require 'db_dump/serialization_helper'

module DbDump
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path('../tasks/base.rake', __FILE__)
    end
  end
end
