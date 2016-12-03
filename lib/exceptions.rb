module Exceptions
  class ApiStandardError < StandardError; end

  class ApiRequestError < ApiStandardError
    def status
      422
    end
  end

  class ApiResourceMissingError < ApiStandardError
    def status
      404
    end
  end

  class FounderAlreadyHasStartup < ApiRequestError; end
  class FounderAlreadyMemberOfStartup < ApiRequestError; end
  class FounderNotFound < ApiResourceMissingError; end

  class IntercomError < StandardError; end
end
