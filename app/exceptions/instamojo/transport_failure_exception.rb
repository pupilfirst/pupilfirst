class Instamojo
  # Raised when a request to Instamojo API fails with either a socket error or any HTTP 5XX errors.
  class TransportFailureException < StandardError
  end
end
