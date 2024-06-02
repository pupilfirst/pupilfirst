# Adapted from: https://github.com/beckn/protocol-specifications/blob/master/docs/BECKN-005-Error-Codes-Draft-01.md
module Beckn::Api
  class ErrorDataService < Beckn::DataService
    def data(code, message)
      { error: { type: "DOMAIN-ERROR", code: code, message: message } }
    end
  end
end
