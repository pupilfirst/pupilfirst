if Settings.sentry.dsn.present?
  require "sentry-ruby"
  require "sentry-rails"

  Sentry.init do |config|
    config.dsn = Settings.sentry.dsn

    # Enable performance monitoring.
    config.enable_tracing = true

    config.environment = Rails.env.to_s

    config.traces_sample_rate = Settings.sentry.traces_sample_rate

    # Get breadcrumbs from logs.
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
  end
end
