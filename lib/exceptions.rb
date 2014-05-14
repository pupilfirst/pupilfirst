module Exceptions
  class ApiRequestError < StandardError; end

  class AuthTokenMissing < ApiRequestError; end
end
