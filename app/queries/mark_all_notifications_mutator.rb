class MarkAllNotificationsMutator < ApplicationQuery
  def mark_all
    notifications.update_all(read_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
  end

  private

  def notifications
    @notifications ||= current_user.notifications.unread
  end

  def authorized_create?
    current_usser.present?
  end
end

