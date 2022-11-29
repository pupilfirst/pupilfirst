class CalendarEvent < ApplicationRecord
  belongs_to :calendar

  validates :title, presence: true
  validates :start_time, presence: true
  validate :ends_at_is_after_starts_at

  def ends_at_is_after_starts_at
    return if end_time.blank? || start_time.blank?

    errors.add(:ends_at, 'must be after starts_at') if ends_at <= starts_at
  end
end
