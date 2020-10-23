module Types
  class NotificationObjectType < Types::BaseEnum
    ::Notification.object_type.map do |key, value|
      value key, "Notification triggered when #{value.split('.').first} is #{value.split('.').second}"
    end
  end
end
