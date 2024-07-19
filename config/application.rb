require_relative "boot"

require "rails/all"
require_relative "../lib/maintenance"

if Rails.env.development?
  require "dotenv"
  Dotenv.load
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Pupilfirst
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.add_autoload_paths_to_load_path = false

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    config.assets.precompile << "delayed/web/application.css"

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.i18n.enforce_available_locales = true

    # include nested directories inside locale
    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.yml")]

    # Precompile fonts.
    config.assets.paths << Rails.root.join("app/assets/fonts")

    # Add some paths to autoload
    %w[presenters services forms/concerns].each do |folder|
      config.autoload_paths.push(Rails.root.join("app", folder))
    end

    # Ensure BatchLoader's cache is purged between requests.
    config.middleware.use BatchLoader::Middleware

    config.middleware.insert_before Rack::Runtime, Maintenance

    # Disables the deprecated #to_s override in some Ruby core classes
    config.active_support.disable_to_s_conversion = true
  end
end

require "flipper"
require "flipper/adapters/active_record"

Flipper.configure do |config|
  config.adapter { Flipper::Adapters::ActiveRecord.new }
end
