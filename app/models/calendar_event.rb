class CalendarEvent < ApplicationRecord
  belongs_to :calendar

  validates :title, presence: true
  validates :start_time, presence: true
  validate :ends_at_is_after_starts_at
  validates_with RateLimitValidator,
                 limit: 100,
                 scope: :calendar_id,
                 time_frame: 1.day

  def ends_at_is_after_starts_at
    return if end_time.blank? || start_time.blank?

    errors.add(:ends_at, "must be after starts_at") if ends_at <= starts_at
  end

  enum color: {
         yellow: "yellow",
         blue: "blue",
         green: "green",
         red: "red",
         orange: "orange"
       },
       _prefix: :color

  def display_time
    start_time.strftime("%-d %b %Y, %H:%M")
  end
end
