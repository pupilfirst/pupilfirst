# Create new services by inherting from this class.
class BaseService
  def log(message)
    print "[#{current_timestamp}] #{message}\n"
  end

  private

  def current_timestamp
    Time.now.strftime('%Y-%m-%dT%H:%M:%S%z')
  end
end
