module Exceptions
  class ApiRequestError < StandardError; end

  class AuthTokenInvalid < ApiRequestError; end
  class RestrictedToSelf < ApiRequestError; end
end
