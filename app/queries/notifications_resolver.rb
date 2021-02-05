class NotificationsResolver < ApplicationQuery
  property :search
  property :status, validates: { inclusion: { in: Types::NotificationStatusType.values.keys } }, allow_blank: true
  property :event, validates: { inclusion: { in: Notification.events.keys.map { |k| k.camelcase } } }, allow_blank: true

  def notifications
    if search.present?
      applicable_notifications.search_by_message(message_for_search)
    else
      applicable_notifications
    end
  end

  private

  def authorized?
    current_user.present?
  end

  def message_for_search
    search.strip
      .gsub(/[^a-z\s0-9]/i, '')
      .split(' ').reject do |word|
      word.length < 3
    end.join(' ')[0..50]
  end

  def filter_by_status
    notifications = current_user.notifications
    return notifications if status.blank?

    case status
      when 'Unread'
        notifications.unread
      when 'Read'
        notifications.read
      else
        notifications
    end
  end

  def applicable_notifications
    notifications = event.present? ? filter_by_status.where(event: event.underscore) : filter_by_status
    notifications.order('created_at DESC')
  end
end
