class IntercomClient
  def initialize(app_id = ENV['INTERCOM_API_ID'], api_key = ENV['INTERCOM_API_KEY'])
    @intercom = Intercom::Client.new(app_id: app_id, api_key: api_key)
  end

  # find a user given his email
  def find_user(email)
    @intercom.users.find(email: email)
  rescue Intercom::ResourceNotFound
    return nil
  end

  # create user with given arguments
  def create_user(args)
    @intercom.users.create(args)
  end

  # find user by email in args or create one with the given args
  def find_or_create_user(args)
    user = args[:email].present? ? find_user(args[:email]) : nil
    user.present? ? user : create_user(args)
  end

  # add a tag to a user
  def add_tag_to_user(user, tag)
    @intercom.tags.tag(name: tag, users: [{ email: user.email }])
  end

  # count of open and closed conversations grouped by admin
  def conversation_count_by_admin
    @conversation_count ||= @intercom.counts.for_type(type: 'conversation', count: 'admin').conversation['admin']
  end

  # total count of open conversations
  def open_conversations_count
    conversation_count_by_admin.inject(0) { |a, e| a + e['open'] }
  end

  # total count of close conversations
  def closed_conversations_count
    conversation_count_by_admin.inject(0) { |a, e| a + e['closed'] }
  end

  # user counts grouped by segments
  def user_count_by_segment
    @user_count ||= @intercom.counts.for_type(type: 'user', count: 'segment').user['segment']
  end

  # total number of new users
  def new_users_count
    user_count_by_segment.find { |h| h.key? 'New' }['New']
  end

  # total number of active users
  def active_users_count
    user_count_by_segment.find { |h| h.key? 'Active' }['Active']
  end

  # fetch the latest n open conversations
  def fetch_open_conversations(n)
    @open_conversations ||= @intercom.conversations.find(open: true, display_as: 'plaintext').conversations[0..n]
  end

  # array of n latest conversations including their id, user's name and body
  def latest_conversation_array(n)
    @conversations_to_display = []
    conversations = @intercom.fetch_open_conversations(n)

    conversations.each do |conversation|
      id = conversation['id']
      user = @intercom.users.find(id: conversation['user']['id'])
      user_name = user.name || (user.email.present? ? user.email : user.pseudonym)
      body = conversation['conversation_message']['body']
      @conversations_to_display << { id: id, name: user_name, body: body }
    end

    @conversations_to_display
  end

  ## Methods below were created for cleaning up user_id from existing intercom users - a one-time correction measure.

  def alter_and_delete(intercom_client, user)
    puts "Altering user #{user.email} who is a dupe of an essential user..."
    components = user.email.split('@')
    new_email = "#{components.first}+#{rand(10_000)}@#{components.last}"
    user.email = new_email
    user.user_id = nil
    intercom_client.users.save(user)

    puts 'Now deleting the same user...'
    intercom_client.users.delete(user)
  end

  # rubocop:disable MethodLength
  def strip_user_ids(intercom_client)
    users = File.read('/Users/hari/code/api-backend/conversing_users.txt').split.each_with_object({}) do |user_line, users_collected|
      components = user_line.split ','
      users_collected[components.first] = components.last
    end

    user_emails = users.values

    intercom_client.users.all.each_with_index do |user, index|
      if user.user_id.nil?
        puts "User ##{index} already has nil user_id. Skipping."
        next
      end

      puts "Stripping user_id from user ##{index} with email '#{user.email}'"

      if user_emails.include?(user.email)
        if users[user.id].present?
          puts "Essential user #{user.email} with ID #{user.id} encountered. Only wiping."
          user.user_id = nil
          intercom_client.users.save(user)
        else
          alter_and_delete(intercom_client, user)
        end
      else
        user.user_id = nil

        begin
          intercom_client.users.save(user)
        rescue Intercom::MultipleMatchingUsersError
          alter_and_delete(intercom_client, user)
        end
      end
    end
  end
  # rubocop:enable MethodLength

  def get_user_data_by_segement(intercom_client, segment_id)
    intercom_client.users.find_all(segment_id: segment_id).each do |user|
      puts "#{user.id},#{user.email}"
    end
  end
end
