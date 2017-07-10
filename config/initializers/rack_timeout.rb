# Recommended to avoid clogging Puma. See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
Rack::Timeout.service_timeout = 20 # seconds
Rack::Timeout::Logger.disable
