
class UserPushNotifyJob
  include SuckerPunch::Job

  def perform(user_id, type, message)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find user_id
      payload = {
        alert: message,
        extra: {
          id: user.id,
          type: 'startup'
        }
      }
      notification = {
        aliases: [user.id],
        ios: {
          aps: payload
        },
        android: payload
      }
      Urbanairship.push(notification)
    end
  end
end
