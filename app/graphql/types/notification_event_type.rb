module Types
  class NotificationEventType < Types::BaseEnum
    ::Notification.events.map do |key, value|
      value key.camelcase, "Notification triggered when #{value.split('.').first} is #{value.split('.').second}"
    end
  end
end
