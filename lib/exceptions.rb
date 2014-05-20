module Exceptions
  class ApiRequestError < StandardError; end

  class AuthTokenInvalid < ApiRequestError; end
  class RestrictedToSelf < ApiRequestError; end
  class UserAlreadyHasStartup < ApiRequestError; end
end
