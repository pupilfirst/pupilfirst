class UserPushNotifyJob < ActiveJob::Base
  # @param [Integer] user_id ID of user to send notification to.
  # @param [String] type Type of push, so that device can identify it.
  # @param [String] message Message to show the user.
  # @param [Hash] extras (Optional) Extra information in payload.
  def perform(user_id, type, message, extras={})
    ActiveRecord::Base.connection_pool.with_connection do
      payload = {
        alert: message,
        extra: {
          id: user_id.to_s,
          type: type
        }.merge(extras)
      }

      notification = {
        aliases: [user_id],
        aps: payload,
        android: payload
      }

      Urbanairship.push(notification)

      Rails.llog.info event: :user_push_notify, user_id: user_id, type: type
    end
  end
end
