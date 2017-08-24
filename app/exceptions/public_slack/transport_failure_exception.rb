module PublicSlack
  # Raised when some HTTP failure occurs during the API call.
  class TransportFailureException < StandardError
  end
end
