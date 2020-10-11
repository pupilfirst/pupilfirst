module RackThrottle
  class Rules < Rack::Throttle::Rules
    def whitelisted?(request)
      return true if request.env['HTTP_COOKIE'].present? && request.env['HTTP_AUTHORIZATION'].blank?
      super
    end
  end
end
