module RackThrottle
  class Rules < Rack::Throttle::Rules
    def whitelisted?(request) # rubocop:disable Naming/InclusiveLanguage
      if request.env['HTTP_COOKIE'].present? &&
           request.env['HTTP_AUTHORIZATION'].blank?
        return true
      end
      super
    end
  end
end
