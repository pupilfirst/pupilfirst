class BatchPushNotifyJob < ActiveJob::Base
  # @param [Array<Integer>] user_ids ID-s of users to send notifications to.
  # @param [String] type Type of push, so that device can identify it.
  # @param [String] message Message to show the user.
  # @param [Hash] extras (Optional) Extra information in payload.
  def perform(user_ids, type, message, extras={})
    ActiveRecord::Base.connection_pool.with_connection do
      notifications = user_ids.map do |user_id|
        payload = {
          alert: message,
          extra: {
            type: type
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
