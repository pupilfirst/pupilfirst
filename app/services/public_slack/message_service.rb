module PublicSlack
  class MessageService
    include Loggable

    class << self
      attr_writer :mock

      def mock?
        defined?(@mock) ? @mock : Rails.env.test? || Rails.env.development?
      end
    end

    def initialize(unfurl_links: false)
      @token = Rails.application.secrets.slack_token
      @errors = {}
      @unfurl_links = unfurl_links
    end

    def valid_channel_names
      channel_list = api.get('channels.list')
      channel_list['channels'].map { |c| '#' + c['name'] }
    end

    def post(message:, **target)
      log "Posting message to target: #{target.keys}"

      if self.class.mock?
        log "Skipping post because of @mock flag. Message was: '#{message}'"
        return OpenStruct.new(errors: @errors)
      end

      channel = target[:channel]
      founder = target[:founder]
      founders = target[:founders]

      # ensure one and only one target is specified
      raise ArgumentError, 'specify one of channel, founder or founders' unless [channel, founder, founders].reject(&:blank?).one?

      if channel.present?
        raise 'could not validate channel specified' unless channel_valid?(channel)

        post_to_channel(channel, message)
      else
        founders.present? ? post_to_founders(founders, message) : post_to_founder(founder, message)
      end

      OpenStruct.new(errors: @errors)
    end

    private

    def api
      @api ||= PublicSlack::ApiService.new(token: @token)
    end

    def channel_valid?(channel)
      channel.in? channel_names_and_ids(public_channels + private_groups)
    end

    def public_channels
      response = api.get('channels.list')

      response['ok'] ? response['channels'] : []
    end

    def private_groups
      response = api.get('groups.list')

      response['ok'] ? response['groups'] : []
    end

    def channel_names_and_ids(channel_list)
      names = channel_list.map { |c| '#' + c['name'] }
      ids = channel_list.map { |c| c['id'] }

      names + ids
    end

    def post_to_channel(channel, message)
      params = message_params(channel, message, @unfurl_links)

      begin
        api.get('chat.postMessage', params: params)
      rescue PublicSlack::TransportFailureException
        @errors['HTTP Error'] = 'There seems to be a network issue. Please try after sometime'
      end
    end

    # Post to each founder in the founders array.
    def post_to_founders(founders, message)
      founders.map { |founder| post_to_founder(founder, message) }
    end

    # Post to founder's im channel.
    def post_to_founder(founder, message)
      channel = fetch_im_id(founder)

      begin
        post_to_channel(channel, message) if channel
      rescue PublicSlack::OperationFailureException => e
        @errors[founder.id] = e.message
      end
    end

    def fetch_im_id(founder)
      # Verify founder has slack_user_id.
      unless founder.slack_user_id
        @errors[founder.id] = 'slack_user_id missing for founder'
        return false
      end

      # Fetch or create im_id for the founder.
      begin
        im_id_response = api.get('im.open', params: { user: founder.slack_user_id })
      rescue PublicSlack::TransportFailureException
        @errors['HTTP Error'] = 'There seems to be a network issue. Please try after sometime'
        return false
      rescue PublicSlack::OperationFailureException => e
        @errors[founder.id] = e.message
        return false
      end

      im_id_response['channel']['id']
    end

    def message_params(channel, message, unfurl_links)
      {
        channel: channel,
        link_names: 1,
        text: message,
        as_user: true,
        unfurl_links: unfurl_links
      }
    end
  end
end
