class MarkNotificationMutator < ApplicationQuery
  property :notification_id, validates: { presence: true }

  validate :must_not_be_marked_as_read

  def mark
    notification.update!(read_at: Time.zone.now)
  end

  private

  def must_not_be_marked_as_read
    return unless notification&.read_at?

    errors[:base] << 'Notification is already marked as read'
  end

  def notification
    @notification ||= current_user.notifications.find_by(id: notification_id)
  end

  def authorized?
    notification.present?
  end
end

