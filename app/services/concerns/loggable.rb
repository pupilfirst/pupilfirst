module Loggable
  extend ActiveSupport::Concern

  def log(message)
    return if Rails.env.test?
    Rails.logger.info "[#{current_timestamp}] #{message}\n"
  end

  private

  def current_timestamp
    Time.now.strftime('%Y-%m-%dT%H:%M:%S%z')
  end
end
