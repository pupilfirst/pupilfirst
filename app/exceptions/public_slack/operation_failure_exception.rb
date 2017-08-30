module PublicSlack
  # Raised if the parsed response did not have the 'ok' property set.
  class OperationFailureException < StandardError
    attr_reader :parsed_response

    def initialize(message, parsed_response)
      @parsed_response = parsed_response
      super message
    end
  end
end
