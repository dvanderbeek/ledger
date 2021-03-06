if ENV.fetch('COVERAGE', false)
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec'
  end
end

ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../config/environment', __FILE__)

require 'rspec/rails'
require 'shoulda/matchers'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |file| require file }

module Features
  # Extend this module in spec/support/features/*.rb
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Features, type: :feature
  config.include Formulaic::Dsl, type: :feature
  config.include Devise::TestHelpers, type: :controller

  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.order = 'random'
  config.use_transactional_fixtures = false
end

ActiveRecord::Migration.maintain_test_schema!
