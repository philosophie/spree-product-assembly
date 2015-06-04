require 'simplecov'
SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'
require 'ffaker'
require 'database_cleaner'

require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'

Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.javascript_driver = :poltergeist
#Capybara.javascript_driver = :selenium_chrome

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f }

require 'spree/testing_support/factories'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/capybara_ext'

# ActiveRecord::Base.logger = Logger.new(STDOUT)

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before :suite do
    Capybara.match = :prefer_exact
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    Rails.cache.clear

    if RSpec.current_example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end

    DatabaseCleaner.start

    create(:store)
  end

  config.after(:each) do
    # Ensure js requests finish processing before advancing to the next test
    wait_for_ajax if RSpec.current_example.metadata[:js]

    DatabaseCleaner.clean
  end

  config.include FactoryGirl::Syntax::Methods
  config.include Spree::TestingSupport::UrlHelpers
end
