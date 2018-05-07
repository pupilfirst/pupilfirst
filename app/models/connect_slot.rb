class ConnectSlot < ApplicationRecord
  belongs_to :faculty
  has_one :connect_request, dependent: :restrict_with_error

  scope :next_week, -> { where('slot_at > ? AND slot_at < ?', next_week_start, next_week_end) }
  scope :upcoming, -> { where('slot_at > ?', Time.now) }

  validates :faculty_id, presence: true
  validates :slot_at, presence: true, uniqueness: { scope: [:faculty_id] }

  validate :faculty_must_be_valid

  # Faculty must have an email address and a marked level
  def faculty_must_be_valid
    return if faculty.blank?
    return if faculty.email.present? && faculty.level.present?
    errors[:faculty] << 'must have email address and level'
  end

  # Used by AA to form label.
  def display_name
    "#{faculty.name} (#{self})"
  end

  # For select input in the form in FacultyController#index.
  def to_s
    slot_at.in_time_zone('Asia/Calcutta').strftime('%b %-d, %-I:%M %p')
  end

  # Slots that haven't been taken up by a request.
  #
  # Use optional_id to add one to the list regardless of its status.
  def self.available(optional_id: nil)
    if optional_id
      where("(id NOT in (SELECT DISTINCT(connect_slot_id) FROM connect_requests) AND slot_at > ?) OR id = #{optional_id}", Time.now)
    else
      where('connect_slots.id NOT in (SELECT DISTINCT(connect_slot_id) FROM connect_requests)').upcoming
    end.order('slot_at ASC')
  end

  # Available slots, 3 to 11 days from now.
  def self.available_for_founder
    available.where(slot_at: (3.days.from_now.beginning_of_day..11.days.from_now.end_of_day))
  end

  def self.next_week_start
    7.days.from_now.beginning_of_week.in_time_zone('Asia/Calcutta')
  end

  def self.next_week_end
    7.days.from_now.end_of_week.in_time_zone('Asia/Calcutta')
  end
end
