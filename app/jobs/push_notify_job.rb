
class PushNotifyJob
  include SuckerPunch::Job

  def perform(klass, id)
  	p klass, id
    ActiveRecord::Base.connection_pool.with_connection do
    	klass_const = klass.capitalize.constantize
      instance = klass_const.find(id)
      Urbanairship.broadcast_push({
    		android: {
    			alert: instance.push_title, extra: {type: klass_const::PUSH_TYPE, id: id.to_s}
    		}
    	})
      instance.update_attributes!(notification_sent: true)
    end
  end
end
