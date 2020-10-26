module Types
  class NotificationEventType < Types::BaseEnum
    ::Notification.events.map do |key, value|
      value key, "Notification triggered when #{value.split('.').first} is #{value.split('.').second}"
    end
  end
end
