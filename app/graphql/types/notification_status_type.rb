module Types
  class NotificationStatusType < Types::BaseEnum
    value ::Notification::NOTIFICATION_READ, "Notification that are read"
    value ::Notification::NOTIFICATION_UNREAD, "Notification that are unread"
  end
end
