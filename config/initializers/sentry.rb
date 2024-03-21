if ENV["SENTRY_DSN"].present?
  require "sentry-ruby"
  require "sentry-rails"

  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]

    # Enable performance monitoring.
    config.enable_tracing = true

    # Get breadcrumbs from logs.
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
  end
end
