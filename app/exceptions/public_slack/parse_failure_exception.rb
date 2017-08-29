module PublicSlack
  # Raised if the response from Slack's API could not be parsed as JSON.
  class ParseFailureException < StandardError
  end
end
