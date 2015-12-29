class PublicSlackTalk
  attr_reader :errors

  def initialize(message:, channel: nil, user: nil, users: nil)
    @channel = channel
    @user = user
    @message = CGI.escape message
    @users = users
    @token = APP_CONFIG[:slack_token]
    @as_user = true
    @unfurl = false
    @errors = []
  end

  # Call this method to post a new message on slack
  # Specify either the channel name (eg: 'general'), user or an array of users
  def self.post_message(message:, **target)
    # ensure one and only one target is specified
    fail ArgumentError, 'specify one of channel, user or users' unless [target[:channel], target[:user], target[:users]].compact.length == 1
    # create a new PublicSlackTalk instance and process it
    new(channel: target[:channel], user: target[:user], users: target[:users], message: message).tap(&:process)
  end

  def process
    # post message to appropriate channel
    if @channel.present?
      fail 'could not validate channel specified' unless channel_valid?
      @channel = ['%23', @channel].join # prepend '#' to channel name
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
    response_json = JSON.parse RestClient.get("https://slack.com/api/chat.postMessage?token=#{@token}&channel=#{@channel}"\
      "&text=#{@message}&as_user=#{@as_user}&unfurl_links=#{@unfurl}")
    @errors << { "Slack" => response_json['error'] } unless response_json['ok']
  rescue RestClient::Exception => err
    @errors << { "RestClient" => err.response.body }
  end

  def channel_valid?
    # fetch list of all channels
    channel_list = JSON.parse RestClient.get("https://slack.com/api/channels.list?token=#{@token}")
    return false unless channel_list['ok']

    # verify channel with given name exists
    channel_names = channel_list['channels'].map { |c| c['name'] }
    channel_names.include? @channel
  end

  def fetch_im_id
    # verify user has slack_user_id
    unless @user.slack_user_id
      errors << { @user.id => 'slack_user_id missing for user' }
      return false
    end

    # fetch im_ids of all users
    ims_list = JSON.parse RestClient.get("https://slack.com/api/im.list?token=#{@token}")
    unless ims_list['ok']
      errors << { @user.id => ims_list['error'] }
      return false
    end

    # verify user has im_id
    user_ids = ims_list['ims'].map { |i| i['user'] }
    index = user_ids.index @user.slack_user_id
    unless index
      errors << { @user.id => 'could not find im id for user' }
      return false
    end

    # return im_id of user
    ims_list['ims'][index]['id']
  end
end
