class BatchPushNotififyJob < ActiveJob::Base

  def perform(user_ids, type, message, extras={})
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
