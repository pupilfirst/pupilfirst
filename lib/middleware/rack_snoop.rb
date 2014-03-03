module Rack
  class Snoop
    def initialize(app)
      @app = app
      @logger = ActiveSupport::Logger.new(::File.join(Rails.root, 'log/', "#{Rails.env}.log"))
    end

    def call(env)
      status, headers, body = @app.call(env)

      case status
      when 200
        # Who needs weekly status reports?
        # @logger.add  @logger.class::INFO, "RESPONSE:: #{body.as_json}"
      else
        # A bit of extra motivation to fix these errors
        @logger.add  @logger.class::ERROR, "RESPONSE:: #{body.as_json}"
      end

      [status, headers, body]
    end
  end
end
