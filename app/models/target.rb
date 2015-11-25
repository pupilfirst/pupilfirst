class Target < ActiveRecord::Base
  belongs_to :startup
  belongs_to :assigner, class_name: 'Faculty'
  has_many :timeline_events

  STATUS_PENDING = 'pending'
  STATUS_DONE = 'done'

  scope :recently_pending, -> { where(status: STATUS_PENDING).where('due_date >= ? OR due_date IS NULL', Time.now).order(due_date: 'desc') }
  scope :expired, -> { where(status: STATUS_PENDING).where('due_date < ?', Time.now).order(due_date: 'desc') }
  scope :recently_completed, -> { where(status: STATUS_DONE).order(completed_at: 'desc').limit(3) }
  scope :for_team, -> { where(role: 'team') }
  scope :not_for_team, -> { where.not(role: 'team') }

  # See en.yml's role
  def self.valid_roles
    %w(team founder) + User.valid_roles
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

  scope :pending, -> { where status: STATUS_PENDING }

  def pending?
    status == STATUS_PENDING
  end

  def done?
    status == STATUS_DONE
  end

  def expired?
    pending? && due_date? && due_date < Time.now
  end

  before_save do
    self.completed_at = done? ? completed_at || Time.now : nil
  end

  def complete!
    update!(status: STATUS_DONE)
  end
end
