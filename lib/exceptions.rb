module Exceptions
  class ApiRequestError < StandardError; end

  class AuthTokenInvalid < ApiRequestError; end
end
