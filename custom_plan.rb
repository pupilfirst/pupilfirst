require 'zeus/rails'

class CustomPlan < Zeus::Rails
  def test
    # require 'simplecov'
    # # SimpleCov.start
    # SimpleCov.start 'rails'

    # require all ruby files
    # Dir["#{Rails.root}/app/**/*.rb"].each { |f| load f }

    # run the tests
    super
  end

  def default_bundle_with_test_env
    ::Rails.env = 'test'
    ENV['RAILS_ENV'] = 'test'
    default_bundle
  end

  def test_console
    console
  end
end

Zeus.plan = CustomPlan.new
