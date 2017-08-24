module PublicSlack
  # Raised if the parsed response did not have the 'ok' property set.
  class OperationFailureException < StandardError
  end
end
