class MarkAllNotificationsMutator < ApplicationQuery
  def mark_all
    current_user.notifications.unread.update_all(read_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
  end

  private

  def authorized?
    current_user.present?
  end
end

