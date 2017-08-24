module Founders
  class SlackConnectService
    include RoutesResolvable

    def initialize(founder)
      @founder = founder
    end

    # @return [String] URL to redirect to where user will be asked to sign in with Slack and grant required permissions.
    def redirect_url
      params = {
        scope: 'users.profile:write',
        redirect_uri: url_helpers.founders_slack_callback_url,
        client_id: Rails.application.secrets.slack.dig(:app, :client_id)
      }

      "https://slack.com/oauth/authorize?scope=?#{params.to_query}"
    end

    # Attempts to validate connection to Slack.
    def connect(_params)
      # noop
    end

    # Disconnects a founder from his / her Slack account.
    def disconnect
      # noop
    end
  end
end
