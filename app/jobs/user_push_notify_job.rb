class UserPushNotifyJob
  include SuckerPunch::Job

  def perform(user_id, type, message)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find user_id
      payload = {
        alert: message,
        extra: {
          id: user.id.to_s,
          type: type.to_s
        }
      }
      notification = {
        aliases: [user.id],
        aps: payload,
        android: payload
      }
      Urbanairship.push(notification)
    end
  end

  # @param [Array<Integer>] user_ids ID-s of users to send notifications to.
  # @param [Symbol] type Type of push, so that device can identify it.
  # @param [String] message Message to show the user.
  # @param [Hash] extras (Optional) Extra information in payload.
  def perform_batch(user_ids, type, message, extras={})
    ActiveRecord::Base.connection_pool.with_connection do
      users = User.where(id: user_ids)

      notifications = users.map do |user|
        payload = {
          alert: message,
          extra: {
            type: type.to_s
          }.merge(extras)
        }

        {
          aliases: [user.id],
          aps: payload,
          android: payload
        }
      end

      Urbanairship.batch_push(notifications)
    end
  end
end
