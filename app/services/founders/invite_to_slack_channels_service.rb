module Founders
  # Invites a founder to all channels in Public Slack.
  class InviteToSlackChannelsService
    include Loggable

    def initialize(founder)
      @founder = founder
    end

    def execute
      # Do not proceed for founders without a stored Slack User ID.
      return if @founder.slack_user_id.blank?

      log "Inviting Founder ##{@founder.id} to public channels..."
      public_channels.each { |channel_id| invite_to_channel('channels', channel_id) }
      log "Inviting Founder ##{@founder.id} to private channels..."
      private_channels.each { |channel_id| invite_to_channel('groups', channel_id) }
      log 'Invitations sent successfully.'
    end

    private

    def invite_to_channel(channel_type, channel_id)
      api(app_token).get("#{channel_type}.invite", params: invite_params(channel_id))
    rescue PublicSlack::OperationFailureException => e
      raise e if e.parsed_response['error'] != 'already_in_channel'
    end

    def public_channels
      @public_channels ||= channel_ids('channels', :public)
    end

    def private_channels
      @private_channels ||= channel_ids('groups', :private)
    end

    def channel_ids(channel_type, secrets_key)
      response = api(bot_token).get("#{channel_type}.list", params: list_params)

      channel_hash = response[channel_type].each_with_object({}) do |channel, hash|
        hash[channel['name']] = channel['id']
      end

      Rails.application.secrets.slack.dig(:channels, secrets_key).map do |channel_name|
        channel_hash[channel_name]
      end
    end

    def list_params
      {
        exclude_archived: true,
        exclude_members: true
      }
    end

    def invite_params(channel_id)
      {
        channel: channel_id,
        user: @founder.slack_user_id
      }
    end

    def bot_token
      Rails.application.secrets.slack.dig(:app, :bot_oauth_token)
    end

    def app_token
      Rails.application.secrets.slack.dig(:app, :oauth_token)
    end

    def api(token)
      @api ||= Hash.new do |hash, key|
        hash[key] = PublicSlack::ApiService.new(token: key)
      end

      @api[token]
    end
  end
end
