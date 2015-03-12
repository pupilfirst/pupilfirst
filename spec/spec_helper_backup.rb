require 'rubygems'

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
load "#{Rails.root.to_s}/db/schema.rb" if ENV['IN_MEM']
require 'rspec/rails'
# require 'rspec/autorun'
require "email_spec"
require 'webmock/rspec'
require 'sucker_punch/testing/inline'

# Require all shared contexts.
Dir[Rails.root.join('spec/support/shared_context/*.rb')].sort.each {|f| require f}

# Disable all net connections
WebMock.disable_net_connect!

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f; }

Dir[Rails.root.join("spec/spec_helpers/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.include Devise::TestHelpers, type: :controller
  config.include ControllerMacros, type: :controller
  config.include DeviseHelpers, type: :request
  # config.include JsonSpec::Helpers, type: :request
  config.include FactoryGirl::Syntax::Methods
  config.include(JsonSpec::Helpers)
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
end
