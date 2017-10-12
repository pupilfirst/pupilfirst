module PublicSlack
  class MessageService
    include Loggable

    class << self
      attr_writer :mock

      def mock?
        defined?(@mock) ? @mock : Rails.env.test? || Rails.env.development?
      end

      def valid_channel_names
        token = Rails.application.secrets.slack_token
        channel_list = JSON.parse(RestClient.get("https://slack.com/api/channels.list?token=#{token}"))
        channel_list['channels'].map { |c| '#' + c['name'] }
      end
    end

    def initialize(unfurl_links: false)
      @token = Rails.application.secrets.slack_token
      @errors = {}
      @unfurl_links = unfurl_links
    end

    def post(message:, **target)
      if self.class.mock?
        log "Skipping post because of @mock flag:\n\n#{message}\n\nto targets: #{target.keys}"
        return
      end

      message = URI.escape message
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

    def channel_valid?(channel)
      channel.in? channel_names_and_ids(public_channels + private_groups)
    end

    def public_channels
      response = get_json "https://slack.com/api/channels.list?token=#{@token}"

      response['ok'] ? response['channels'] : []
    end

    def private_groups
      response = get_json "https://slack.com/api/groups.list?token=#{@token}"

      response['ok'] ? response['groups'] : []
    end

    def channel_names_and_ids(channel_list)
      names = channel_list.map { |c| '#' + c['name'] }
      ids = channel_list.map { |c| c['id'] }

      names + ids
    end

    def post_to_channel(channel, message)
      # Make channel name url safe by replacing '#' with '%23', if any.
      channel = '%23' + channel[1..-1] if channel[0] == '#'

      response = get_json "https://slack.com/api/chat.postMessage?token=#{@token}&channel=#{channel}&link_names=1"\
      "&text=#{message}&as_user=true&unfurl_links=#{@unfurl_links}"
      @errors[channel] = response['error'] unless response['ok']
    rescue RestClient::Exception => err
      @errors['RestClient'] = err.response.body
    end

    # Post to each founder in the founders array.
    def post_to_founders(founders, message)
      founders.map { |founder| post_to_founder(founder, message) }
    end

    # Post to founder's im channel.
    def post_to_founder(founder, message)
      channel = fetch_im_id(founder)
      post_to_channel(channel, message) if channel
    end

    def fetch_im_id(founder)
      # Verify founder has slack_user_id.
      unless founder.slack_user_id
        @errors[founder.id] = 'slack_user_id missing for founder'
        return false
      end

      # Fetch or create im_id for the founder.
      im_id_response = get_json "https://slack.com/api/im.open?token=#{@token}&user=#{founder.slack_user_id}"
      unless im_id_response['ok']
        @errors[founder.id] = im_id_response['error']
        return false
      end

      im_id_response['channel']['id']
    end

    def get_json(url)
      JSON.parse(RestClient.get(url))
    end
  end
end
