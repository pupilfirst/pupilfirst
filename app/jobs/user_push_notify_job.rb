
class UserPushNotifyJob
  include SuckerPunch::Job

  def perform(user_id, type, message)
    type = :startup
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
end
