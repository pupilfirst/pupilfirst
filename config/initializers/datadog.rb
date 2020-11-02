# frozen_string_literal: true

default_adapter = proc { |t| t.adapter :net_http, '127.0.0.1', 8126, { timeout: 1 } }
test_adapter    = proc { |t| t.adapter :test }

Datadog.configure do |c|
  c.tracer.transport_options = Rails.env.production? ? default_adapter : test_adapter

  c.env                     = Rails.env.to_s
  c.service                 = 'growthtribe-lms-production'
  c.version                 = ENV["HEROKU_SLUG_COMMIT"]
  c.runtime_metrics.enabled = true

  c.use :rails, log_injection: true, analytics_enabled: nil
  c.use :sidekiq, analytics_enabled: nil
end
