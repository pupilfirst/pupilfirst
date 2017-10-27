module PublicSlack
  # Posts a message to multiple channels on Public Slack honoring the Slack rate limit.
  class PostEnglishQuestionJob < ApplicationJob
    queue_as :default

    include Loggable

    def perform(attachments:, channels:)
      success_count = 0

      channels.each do |channel|
        begin
          params = { channel: channel, as_user: true, attachments: attachments }
          response = api_service.get('chat.postMessage', params: params)
        rescue PublicSlack::OperationFailureException
          next # ignore Slack exceptions for now.
        else
          success_count += 1 if response['ok']
          sleep 1 # because Slack rate-limits to 1 req/sec.
        end
      end

      log "Successfully posted English question of the day to #{success_count} of #{channels.count} founders"
    end

    private

    def api_service
      @api_service ||= begin
        token = Rails.application.secrets.slack.dig(:app, :bot_oauth_token)
        PublicSlack::ApiService.new(token: token)
      end
    end
  end
end
