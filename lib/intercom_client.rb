class IntercomClient
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
