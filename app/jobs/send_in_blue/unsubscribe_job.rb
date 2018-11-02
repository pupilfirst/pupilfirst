module SendInBlue
  class UnsubscribeJob < ApplicationJob
    queue_as :default

    def perform(email)
      url = "https://api.sendinblue.com/v3/contacts/#{CGI.escape(email)}"

      RestClient.put(
        url,
        { emailBlacklisted: true }.to_json,
        content_type: :json, 'api-key': Rails.application.secrets.send_in_blue[:v3_api_key]
      )
    rescue RestClient::NotFound => e
      response = JSON.parse(e.response)
      return if response['code'] == 'document_not_found' # Ignore if the contact was not found on SendInBlue.

      raise
    end
  end
end
