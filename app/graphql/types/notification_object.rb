module Types
  class NotificationObject < Types::BaseEnum
    ::Notification.objects.map do |key, value|
      value key, "Notification triggered when #{value.split('.').first} is #{value.split('.').second}"
    end
  end
end
