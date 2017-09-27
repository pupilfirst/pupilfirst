class Instamojo
  # Raised when the response from Instamojo API doesn't have the 'success' flag set.
  class RequestFailedException < StandardError
  end
end
