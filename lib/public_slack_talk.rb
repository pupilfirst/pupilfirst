class PublicSlackTalk
  def initialize(message:, channel: nil, user: nil, users: nil)
    @channel = channel
    @user = user
    @message = message
    @users = users
    @token = APP_CONFIG[:slack_token]
    @as_user = true
    @unfurl = false
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
      return false unless channel_valid?
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
    RestClient.get "https://slack.com/api/chat.postMessage?token=#{@token}&channel=#{@channel}"\
      "&text=#{@message}&as_user=#{@as_user}&unfurl_links=#{@unfurl}"
  end

  def channel_valid?
    # fetch list of all channels
    channel_list = JSON.parse RestClient.get("https://slack.com/api/channels.list?token=#{@token}")
    return false unless channel_list['ok']

    # verify channel with given name exists
    channel_names = channel_list['channels'].map { |c| c['name'] }
    return false unless channel_names.include? @channel
    true
  end

  def fetch_im_id
    # verify user has slack_user_id
    return false unless @user.slack_user_id

    # fetch im_ids of all users
    ims_list = JSON.parse RestClient.get("https://slack.com/api/im.list?token=#{@token}")
    return false unless ims_list['ok']

    # verify user has im_id
    user_ids = ims_list['ims'].map { |i| i['user'] }
    index = user_ids.index @user.slack_user_id
    return false unless index

    # return im_id of user
    ims_list['ims'][index]['id']
  end
end
