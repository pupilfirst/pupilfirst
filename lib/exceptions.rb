module Exceptions
  class ApiRequestError < StandardError
    def status
      422
    end
  end

  class ApiResourceMissingError < StandardError
    def status
      404
    end
  end

  class AuthTokenInvalid < ApiRequestError; end
  class RestrictedToSelf < ApiRequestError; end
  class UserAlreadyHasStartup < ApiRequestError; end
  class UserAlreadyMemberOfStartup < ApiRequestError; end
  class NoSuchFounderForDeletion < ApiResourceMissingError; end
  class DeleteFounderPrivilegeMissing < ApiRequestError; end
end
