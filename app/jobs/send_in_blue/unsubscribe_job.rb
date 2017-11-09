module SendInBlue
  class UnsubscribeJob < ApplicationJob
    queue_as :default

    def perform(email)
      url = "https://api.sendinblue.com/v3/contacts/#{email}"
      RestClient.put(
        url,
        { emailBlacklisted: true }.to_json,
        content_type: :json, 'api-key': api_key
      )
    end

    private

    def api_key
      Rails.application.secrets.send_in_blue[:v3_api_key]
    end
  end
end
