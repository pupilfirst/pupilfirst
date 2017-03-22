module Intercom
  # This is a test light-weight API client for Intercom that can be used to manually hit URL-s, bypassing
  # their heavy client library - Hari Gopal.
  class ApiClient
    def initialize
      @base_url = 'https://api.intercom.io'
      @access_token = Rails.application.secrets.intercom_access_token
    end

    def get(path, params = {})
      # Refactor the following line.
      path = path[1..path.length] if path.starts_with?('/')

      url = [@base_url, path].join('/')

      payload = {
        Authorization: "Bearer #{@access_token}",
        Accept: 'application/json'
      }

      payload[:params] = params if params.present?

      response = RestClient.get(url, payload)
      JSON.parse(response.body)
    end
  end
end
