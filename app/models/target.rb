class Target < ActiveRecord::Base
  belongs_to :startup
  belongs_to :assigner, class_name: 'Faculty'
  has_many :timeline_events

  STATUS_PENDING = 'pending'
  STATUS_DONE = 'done'

  # The following definitions of pending and expired is naive. A correct check requires the use of the done_for_viewer?
  # method on individual targets by supplying the viewer.
  scope :pending, -> { where(status: STATUS_PENDING).where('due_date >= ? OR due_date IS NULL', Time.now).order(due_date: 'desc') }
  scope :expired, -> { where(status: STATUS_PENDING).where('due_date < ?', Time.now).order(due_date: 'desc') }

  scope :recently_completed, -> { where(status: STATUS_DONE).order(completed_at: 'desc').limit(3) }
  scope :team, -> { where(role: ROLE_TEAM) }
  scope :founder, -> { where(role: ROLE_FOUNDER) }
  scope :not_target_roles, -> { where.not(role: target_roles) }

  ROLE_FOUNDER = 'founder'
  ROLE_TEAM = 'team'

  def self.target_roles
    [ROLE_TEAM, ROLE_FOUNDER]
  end

  # See en.yml's target.role
  def self.valid_roles
    target_roles + User.valid_roles
  end

  # See en.yml's target.status
  def self.valid_statuses
    %w(pending done)
  end

  validates_presence_of :startup_id, :assigner_id, :role, :title, :short_description, :status
  validates_inclusion_of :role, in: valid_roles
  validates_inclusion_of :status, in: valid_statuses

  just_define_datetime_picker :due_date
  just_define_datetime_picker :completed_at

  # A target is pending if it isn't marker done, or isn't expired.
  def pending?
    !(done? || expired?)
  end

  # This is a naive check. See done_for_viewer?
  def done?
    status == STATUS_DONE
  end

  # This checks for presence of a linked verified timeline event if role of target is founder.
  def done_for_viewer?(viewer)
    return true if done?
    return done? unless role == ROLE_FOUNDER
    timeline_events.where(user: viewer).merge(TimelineEvent.verified).present?
  end

  # Stored status must be pending, and due date must be present and in the past.
  def expired?
    (status == STATUS_PENDING) && due_date? && (due_date < Time.now)
  end

  # Set and clear completed at, depending on the value of stored status.
  before_save do
    self.completed_at = (status == STATUS_DONE) ? completed_at || Time.now : nil
  end

  def complete!
    update!(status: STATUS_DONE)
  end
end
