class ConnectSlot < ApplicationRecord
  belongs_to :faculty
  has_one :connect_request, dependent: :destroy

  scope :next_week, -> { where('slot_at > ? AND slot_at < ?', next_week_start, next_week_end) }
  scope :upcoming, -> { where('slot_at > ?', Time.zone.now) }

  # Slots that haven't been taken up by a request.
  scope :available, -> { upcoming.includes(:connect_request).where(connect_requests: { id: nil }) }

  # Available slots, 1 to 11 days from now.
  scope :available_for_founder, -> { available.where(slot_at: (1.day.from_now.beginning_of_day..11.days.from_now.end_of_day)) }

  validates :faculty_id, presence: true
  validates :slot_at, presence: true, uniqueness: { scope: [:faculty_id] } # rubocop:disable Rails/UniqueValidationWithoutIndex

  # Used by AA to form label.
  def display_name
    "#{faculty.name} (#{self})"
  end

  # For select input in the form in FacultyController#index.
  def to_s
    slot_at.in_time_zone('Asia/Calcutta').strftime('%b %-d, %-I:%M %p')
  end

  def self.next_week_start
    7.days.from_now.beginning_of_week.in_time_zone('Asia/Calcutta')
  end

  def self.next_week_end
    7.days.from_now.end_of_week.in_time_zone('Asia/Calcutta')
  end
end
