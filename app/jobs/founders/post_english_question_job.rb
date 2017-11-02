module Founders
  # Posts a message with attachment to the specified channel on Public Slack honoring the Slack rate limit.
  class PostEnglishQuestionJob < ApplicationJob
    queue_as :low_priority

    include Loggable

    def perform(attachments:, channel:)
      # Wait 1 sec to account for a possible PostEnglishQuestionJob just over.
      sleep 1

      # Instantiate the API service.
      token = Rails.application.secrets.slack.dig(:app, :bot_oauth_token)
      api_service = PublicSlack::ApiService.new(token: token)

      # Post the English Question.
      params = { channel: channel, as_user: true, attachments: attachments }
      response = api_service.get('chat.postMessage', params: params)
      log "Successfully posted English Question of the day to #{channel}" if response['ok']
    rescue PublicSlack::OperationFailureException
      return # ignore Slack exceptions for now.
    end
  end
end
