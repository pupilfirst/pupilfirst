# Create new services by inherting from this class.
class BaseService
  def log(message)
    return if Rails.env.test?
    print "[#{current_timestamp}] #{message}\n"
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  private

  def current_timestamp
    Time.now.strftime('%Y-%m-%dT%H:%M:%S%z')
  end
end
