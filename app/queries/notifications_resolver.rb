class NotificationsResolver < ApplicationQuery
  property :search
  property :unread
  property :event, validates: { inclusion: { in: Notification.events.keys } }, allow_blank: true
  property :sort_direction

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

  def sort_direction_string
    case sort_direction
      when 'Ascending'
        'ASC'
      when 'Descending'
        'DESC'
      else
        'DESC'
    end
  end

  def filter_by_read
    notifications = current_user.notifications
    return notifications if unread.blank?

    unread ? notifications.unread : notifications.read
  end

  def filter_by_event
    event.present? ? filter_by_read.where(event: event) : filter_by_read
  end

  def applicable_notifications
    filter_by_event.order("notifications.created_at #{sort_direction_string}")
  end
end
