require_relative 'boot'
require 'rails/all'

if Rails.env.development?
  require 'dotenv'
  Dotenv.load
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Pupilfirst
  class Application < Rails::Application
    VERSION = '2021.1'

    # Initialize configuration defaults for originally generated Rails version.
    #
    # Note: This is not the original Rails version. However, this is the easiest way to enforce the latest defaults.
    config.load_defaults 6.0

    config.assets.precompile << 'delayed/web/application.css'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.i18n.enforce_available_locales = true

    # include nested directories inside locale
    config.i18n.load_path += Dir[Rails.root.join('config/locales/**/*.yml')]

    # Precompile fonts.
    config.assets.paths << Rails.root.join('app/assets/fonts')

    # Add some paths to autoload
    %w[presenters services forms/concerns].each do |folder|
      config.autoload_paths.push(Rails.root.join('app', folder))
    end

    # Ensure BatchLoader's cache is purged between requests.
    config.middleware.use BatchLoader::Middleware
  end
end
