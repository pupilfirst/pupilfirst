module Loggable
  extend ActiveSupport::Concern

  def log(message)
    return if Rails.env.test?

    Rails.logger.info "[#{current_timestamp}] [#{current_service_name}] #{message}\n"
  end

  private

  def current_service_name
    self.class.to_s
  end

  def current_timestamp
    Time.now.strftime('%Y-%m-%dT%H:%M:%S%z')
  end
end
