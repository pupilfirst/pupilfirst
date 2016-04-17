class PublicSlackTalk
  attr_reader :errors

  # add a mock attribute to help disable slack talks during tests
  class << self
    attr_accessor :mock
  end

  # TODO: A faculty can double as a founder argument. Either rename the argument to accomodate or modify to accept a
  # faculty argument which works exactly like a founder argument.
  def initialize(message:, channel: nil, founder: nil, founders: nil)
    @channel = channel
    @founder = founder
    @message = CGI.escape message
    @founders = founders
    @token = APP_CONFIG[:slack_token]
    @as_user = true
    @unfurl = false
    @errors = {}
  end

  # Call this method to post a new message on slack
  # Specify either the channel name (eg: 'general'), founder or an array of founders
  def self.post_message(message:, **target)
    # skip if in development environment
    return if Rails.env.development?

    # Skip if in mock mode.
    return if mock

    # ensure one and only one target is specified
    raise ArgumentError, 'specify one of channel, founder or founders' unless [target[:channel], target[:founder], target[:founders]].compact.length == 1

    # create a new PublicSlackTalk instance and process it
    new(channel: target[:channel], founder: target[:founder], founders: target[:founders], message: message).tap(&:process)
  end

  def process
    # post message to appropriate channel
    if @channel.present?
      raise'could not validate channel specified' unless channel_valid?
      post_to_channel
    end
    post_to_founder if @founder.present?
    post_to_founders if @founders.present?
  end

  def post_to_founder
    # post to founder's im channel
    @channel = fetch_im_id
    post_to_channel if @channel
  end

  def post_to_founders
    # post to each founder in the founders array
    @founders.each do |u|
      @founder = u
      post_to_founder
    end
  end

  def post_to_channel
    # make channel name url safe by replacing '#' with '%23' if any
    @channel = '%23' + @channel[1..-1] if @channel[0] == '#'

    response_json = JSON.parse RestClient.get("https://slack.com/api/chat.postMessage?token=#{@token}&channel=#{@channel}"\
      "&text=#{@message}&as_user=#{@as_user}&unfurl_links=#{@unfurl}")
    error_key = @founder.present? ? @founder.id : 'Slack'
    @errors[error_key] = response_json['error'] unless response_json['ok']
  rescue RestClient::Exception => err
    error_key = @founder.present? ? @founder.id : 'RestClient'
    @errors[error_key] = err.response.body
  end

  def channel_valid?
    # fetch list of all channels
    channel_list = JSON.parse RestClient.get("https://slack.com/api/channels.list?token=#{@token}")
    return false unless channel_list['ok']

    # verify channel with given name or id exists
    channel_names = channel_list['channels'].map { |c| '#' + c['name'] }
    channel_ids = channel_list['channels'].map { |c| c['id'] }
    (channel_names + channel_ids).include? @channel
  end

  def fetch_im_id
    # verify founder has slack_user_id
    unless @founder.slack_user_id
      @errors[@founder.id] = 'slack_user_id missing for founder'
      return false
    end

    # fetch or create im_id for the founder
    im_id_response = JSON.parse RestClient.get("https://slack.com/api/im.open?token=#{@token}&user=#{@founder.slack_user_id}")
    unless im_id_response['ok']
      @errors[@founder.id] = im_id_response['error']
      return false
    end

    im_id_response['channel']['id']
  end
end
