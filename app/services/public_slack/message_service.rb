module PublicSlack
  class MessageService
    attr_reader :errors

    class << self
      attr_writer :mock

      def mock?
        defined?(@mock) ? @mock : Rails.env.test? || Rails.env.development?
      end
    end

    def initialize
      @token = Rails.application.secrets.slack_token
      @errors = {}
    end

    def execute(message:, **target)
      return if self.class.mock?

      @message = URI.escape message
      @channel = target[:channel]
      @founder = target[:founder]
      @founders = target[:founders]

      # ensure one and only one target is specified
      raise ArgumentError, 'specify one of channel, founder or founders' unless [@channel, @founder, @founders].one?

      if @channel.present?
        raise 'could not validate channel specified' unless channel_valid?
        post_to_channel
      else
        @founders.present? ? post_to_founders : post_to_founder
      end

      self
    end

    def valid_channel_names
      channel_list = get_json "https://slack.com/api/channels.list?token=#{@token}"
      channel_list['channels'].map { |c| '#' + c['name'] }
    end

    private

    def channel_valid?
      # fetch list of all channels
      channel_list = get_json "https://slack.com/api/channels.list?token=#{@token}"
      return false unless channel_list['ok']

      # verify channel with given name or id exists
      channel_names = channel_list['channels'].map { |c| '#' + c['name'] }
      channel_ids = channel_list['channels'].map { |c| c['id'] }
      @channel.in?(channel_names + channel_ids)
    end

    def post_to_channel(channel = @channel)
      # make channel name url safe by replacing '#' with '%23' if any
      channel = '%23' + channel[1..-1] if channel[0] == '#'

      response = get_json "https://slack.com/api/chat.postMessage?token=#{@token}&channel=#{channel}&link_names=1"\
      "&text=#{@message}&as_user=true&unfurl_links=false"
      error_key = @founder.present? ? @founder.id : 'Slack'
      @errors[error_key] = response['error'] unless response['ok']
    rescue RestClient::Exception => err
      error_key = @founder.present? ? @founder.id : 'RestClient'
      @errors[error_key] = err.response.body
    end

    def post_to_founders
      # post to each founder in the founders array
      @founders.map { |founder| post_to_founder(founder) }
    end

    def post_to_founder(founder = @founder)
      # post to founder's im channel
      channel = fetch_im_id(founder)
      post_to_channel(channel) if channel
    end

    def fetch_im_id(founder)
      # verify founder has slack_user_id
      unless founder.slack_user_id
        @errors[founder.id] = 'slack_user_id missing for founder'
        return false
      end

      # fetch or create im_id for the founder
      im_id_response = get_json "https://slack.com/api/im.open?token=#{@token}&user=#{founder.slack_user_id}"
      unless im_id_response['ok']
        @errors[founder.id] = im_id_response['error']
        return false
      end

      im_id_response['channel']['id']
    end

    def get_json(url)
      JSON.parse RestClient.get(url)
    end
  end
end
