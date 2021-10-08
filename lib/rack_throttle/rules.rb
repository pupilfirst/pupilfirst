module RackThrottle
  class Rules < Rack::Throttle::Rules
    def whitelisted?(request)
      if request.env['HTTP_COOKIE'].present? &&
           request.env['HTTP_AUTHORIZATION'].blank?
        return true
      end
      super
    end
  end
end
