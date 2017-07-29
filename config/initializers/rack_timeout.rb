# Recommended to avoid clogging Puma. See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
Rack::Timeout.service_timeout = Rails.env.production? ? 20 : 120 # seconds
Rack::Timeout::Logger.disable
