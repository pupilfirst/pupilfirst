class ConnectRequest < ActiveRecord::Base
  belongs_to :connect_slot
  belongs_to :startup

  delegate :faculty, :slot_at, to: :connect_slot

  validates_presence_of :connect_slot_id, :startup_id, :questions, :status
  validates_uniqueness_of :connect_slot_id

  STATUS_REQUESTED = 'requested'
  STATUS_CONFIRMED = 'confirmed'

  def self.valid_statuses
    [STATUS_REQUESTED, STATUS_CONFIRMED]
  end

  validates_inclusion_of :status, in: valid_statuses

  MAX_QUESTIONS_LENGTH = 600

  validates_length_of :questions, maximum: MAX_QUESTIONS_LENGTH

  def require_meeting_link_for_confirmed
    return unless confirmed?
    return if confirmed? && meeting_link.present?
    errors[:status] << 'can be confirmed only with meeting link'
    errors[:meeting_link] << 'must be present for confirmed state'
  end

  validate :require_meeting_link_for_confirmed

  before_validation :set_status_for_nil

  def set_status_for_nil
    self.status = STATUS_REQUESTED if status.nil?
  end

  after_save :send_mails_for_confirmed

  def send_mails_for_confirmed
    return unless status_changed? && confirmed?
    FacultyMailer.connect_request_confirmed(self).deliver_later
    StartupMailer.connect_request_confirmed(self).deliver_later
  end

  # Set status to confirmed.
  def confirm!
    update!(status: STATUS_CONFIRMED)

    # TODO: Mails should be sent out.
  end

  def requested?
    status == STATUS_REQUESTED
  end

  def confirmed?
    status == STATUS_CONFIRMED
  end
end
