class PublicSlackTalk
  attr_reader :errors

  # add a mock attribute to help disable slack talks during tests
  class << self
    attr_accessor :mock
  end

  def initialize(message:, channel: nil, user: nil, users: nil)
    @channel = channel
    @user = user
    @message = CGI.escape message
    @users = users
    @token = APP_CONFIG[:slack_token]
    @as_user = true
    @unfurl = false
    @errors = {}
  end

  # Call this method to post a new message on slack
  # Specify either the channel name (eg: 'general'), user or an array of users
  def self.post_message(message:, **target)
    # skip if in development environment
    return if Rails.env.development?

    # Skip if in mock mode.
    return if mock

    # ensure one and only one target is specified
    fail ArgumentError, 'specify one of channel, user or users' unless [target[:channel], target[:user], target[:users]].compact.length == 1

    # create a new PublicSlackTalk instance and process it
    new(channel: target[:channel], user: target[:user], users: target[:users], message: message).tap(&:process)
  end

  def process
    # post message to appropriate channel
    if @channel.present?
      fail 'could not validate channel specified' unless channel_valid?
      post_to_channel
    end
    post_to_user if @user.present?
    post_to_users if @users.present?
  end

  def post_to_user
    # post to user's im channel
    @channel = fetch_im_id
    post_to_channel if @channel
  end

  def post_to_users
    # post to each user in the users array
    @users.each do |u|
      @user = u
      post_to_user
    end
  end

  def post_to_channel
    # make channel name url safe by replacing '#' with '%23' if any
    @channel = '%23' + @channel[1..-1] if @channel[0] == '#'

    response_json = JSON.parse RestClient.get("https://slack.com/api/chat.postMessage?token=#{@token}&channel=#{@channel}"\
      "&text=#{@message}&as_user=#{@as_user}&unfurl_links=#{@unfurl}")
    error_key = @user.present? ? @user.id : 'Slack'
    @errors[error_key] = response_json['error'] unless response_json['ok']
  rescue RestClient::Exception => err
    error_key = @user.present? ? @user.id : 'RestClient'
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
    # verify user has slack_user_id
    unless @user.slack_user_id
      @errors[@user.id] = 'slack_user_id missing for user'
      return false
    end

    # fetch or create im_id for the user
    im_id_response = JSON.parse RestClient.get("https://slack.com/api/im.open?token=#{@token}&user=#{@user.slack_user_id}")
    unless im_id_response['ok']
      @errors[@user.id] = im_id_response['error']
      return false
    end

    im_id_response['channel']['id']
  end
end
