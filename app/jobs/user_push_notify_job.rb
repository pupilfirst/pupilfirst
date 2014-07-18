class UserPushNotifyJob
  include SuckerPunch::Job

  def perform(user_id, type, message, extras={})
    ActiveRecord::Base.connection_pool.with_connection do
      payload = {
        alert: message,
        extra: {
          id: user_id.to_s,
          type: type.to_s
        }.merge(extras)
      }
      notification = {
        aliases: [user_id],
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
      notifications = user_ids.map do |user_id|
        payload = {
          alert: message,
          extra: {
            type: type.to_s
          }.merge(extras)
        }

        {
          aliases: [user_id],
          aps: payload,
          android: payload
        }
      end

      Urbanairship.batch_push(notifications)
    end
  end
end
