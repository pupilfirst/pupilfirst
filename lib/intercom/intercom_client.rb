class IntercomClient
  def intercom_client
    @intercom_client ||= Intercom::Client.new(token: ENV.fetch('INTERCOM_ACCESS_TOKEN'))
  end

  def rescued_call
    yield
  rescue Intercom::ResourceNotFound, Intercom::MultipleMatchingUsersError
    raise
  rescue Intercom::IntercomError => e
    raise Exceptions::IntercomError, "#{e.class}: #{e.message}}"
  end

  def all_users
    @all_users ||= rescued_call { intercom_client.users.all.to_a }
  end

  # find a user given his email
  def find_user(email)
    rescued_call { intercom_client.users.find(email: email) }
  rescue Intercom::ResourceNotFound
    nil
  end

  # create user with given arguments and user_id as nil
  def create_user(args)
    args[:user_id] = nil
    rescued_call { intercom_client.users.create(args) }
  end

  def delete_user(email)
    user = find_user(email)
    rescued_call { intercom_client.users.delete(user) }
  end

  # find user by email in args or create one with the given args
  def find_or_create_user(args)
    user = args[:email].present? ? find_user(args[:email]) : nil
    user.presence || create_user(args)
  end

  def save_user(user)
    rescued_call { intercom_client.users.save(user) }
  end

  # add a tag to a user
  def add_tag_to_user(user, tag)
    user_id = find_user(user.email)&.id
    rescued_call { intercom_client.tags.tag(name: tag, users: [{ id: user_id }]) } if user_id.present?
  end

  # add internal note to a user
  def add_note_to_user(user, note)
    user_id = find_user(user.email)&.user_id
    rescued_call { intercom_client.notes.create(body: note, user_id: user_id) } if user_id.present?
  end

  # add phone as custom attribute to a user
  def add_phone_to_user(user, phone)
    user.custom_attributes[:phone] = phone
    save_user(user)
  end

  def add_college_to_user(user, college)
    user.custom_attributes[:college] = college
    save_user(user)
  end

  def add_university_to_user(user, university)
    user.custom_attributes[:university] = university
    save_user(user)
  end

  def update_user(user, attributes)
    attributes.each do |name, value|
      user.custom_attributes[name.to_sym] = value
    end
    save_user(user)
  end

  # count of open, closed, assigned and unassigned conversations
  def conversation_count
    @conversation_count ||= rescued_call { intercom_client.counts.for_type(type: 'conversation') }
  end

  # total count of open conversations
  def open_conversations_count
    conversation_count.conversation['open']
  end

  # total count of close conversations
  def closed_conversations_count
    conversation_count.conversation['closed']
  end

  # total count of assigned conversations
  def assigned_conversations_count
    conversation_count.conversation['assigned']
  end

  # total count of unassigned conversations
  def unassigned_conversations_count
    conversation_count.conversation['unassigned']
  end

  # user counts grouped by segments
  def user_count_by_segment
    @user_count_by_segment ||= rescued_call { intercom_client.counts.for_type(type: 'user', count: 'segment').user['segment'] }
  end

  # total number of new users
  def new_users_count
    return 0 if user_count_by_segment.blank?

    new_segment = user_count_by_segment.find { |h| h.key? 'New' }
    new_segment.present? ? new_segment['New'] : 0
  end

  # total number of active users
  def active_users_count
    return 0 if user_count_by_segment.blank?

    active_segment = user_count_by_segment.find { |h| h.key? 'Active' }
    active_segment.present? ? active_segment['Active'] : 0
  end

  # fetch the latest n open conversations
  def open_conversations(count)
    @open_conversations ||= rescued_call { intercom_client.conversations.find(open: true, display_as: 'plaintext').conversations[0..count] }
  end

  # array of n latest conversations including their id, user's name and body
  def latest_conversation_array(count)
    @conversations_to_display = []
    conversations = open_conversations(count)

    conversations.each do |conversation|
      id = conversation['id']
      user = rescued_call { intercom_client.users.find(id: conversation['user']['id']) }
      user_name = user.name || (user.email.presence || user.pseudonym)
      body = conversation['conversation_message']['body']
      @conversations_to_display << { id: id, name: user_name, body: body }
    end

    @conversations_to_display
  end

  # sets the user_id as nil for a user with the given email
  def strip_user_id(email)
    user = find_user(email)

    return unless user.present? && user.user_id.present?

    user.user_id = nil
    save_user(user)
  end

  ## Methods below were created for cleaning up user_id from existing intercom users - a one-time correction measure.

  def alter_and_delete(user)
    Rails.logger.info "Altering user #{user.email} who is a dupe of an essential user..."
    components = user.email.split('@')
    new_email = "#{components.first}+#{rand(10_000)}@#{components.last}"
    user.email = new_email
    user.user_id = nil
    rescued_call { intercom_client.users.save(user) }

    Rails.logger.info 'Now deleting the same user...'
    rescued_call { intercom_client.users.delete(user) }
  end

  # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/AbcSize
  def strip_user_ids_from_segment(segment_name)
    users = get_users_by_segment(segment_name)

    raise 'No Users found in the Segment' if users.blank?

    user_emails = users.values

    all_users.each_with_index do |user, index|
      if user.user_id.nil?
        Rails.logger.info "User ##{index} already has nil user_id. Skipping."
        next
      end

      Rails.logger.info "Stripping user_id from user ##{index} with email '#{user.email}'"

      if user_emails.include?(user.email)
        if users[user.id].present?
          Rails.logger.info "Essential user #{user.email} with ID #{user.id} encountered. Only wiping."
          user.user_id = nil
          rescued_call { intercom_client.users.save(user) }
        else
          alter_and_delete(user)
        end
      else
        user.user_id = nil

        begin
          rescued_call { intercom_client.users.save(user) }
        rescue Intercom::MultipleMatchingUsersError
          alter_and_delete(user)
        end
      end
    end
  end

  # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/AbcSize

  def get_segment_id(segment_name)
    segment_id = nil

    rescued_call { intercom_client.segments.all }.each do |segment|
      next unless segment.name == segment_name

      segment_id = segment.id
    end

    segment_id
  end

  def get_users_by_segment(segment_name)
    segment_id = get_segment_id(segment_name)

    raise 'Could not Fetch Segment Id' if segment_id.blank?

    users_by_segment = {}

    rescued_call { intercom_client.users.find_all(segment_id: segment_id) }.each do |user|
      users_by_segment[user.id] = user.email
    end

    users_by_segment
  end
end
