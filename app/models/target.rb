class Target < ActiveRecord::Base
  belongs_to :startup
  belongs_to :assigner, class_name: 'AdminUser'

  scope :recently_pending, -> { where(status: 'pending').where('due_date >= ? OR due_date IS NULL', 2.days.ago).order(due_date: 'desc') }
  scope :recently_completed, -> { where(status: 'done').order(completed_at: 'desc').limit(3) }

  # See en.yml's role
  def self.valid_roles
    %w(team) + User.valid_roles
  end

  # See en.yml's target.status
  def self.valid_statuses
    %w(pending done)
  end

  validates_presence_of :startup_id, :assigner_id, :role, :title, :short_description, :status, :resource_url
  validates_inclusion_of :role, in: valid_roles
  validates_inclusion_of :status, in: valid_statuses

  just_define_datetime_picker :due_date

  def pending?
    status == 'pending'
  end

  def done?
    status == 'done'
  end

  def expired?
    pending? && due_date? && due_date < Time.now
  end

  before_save do
    self.completed_at = (status_changed? && done?) ? completed_at || Time.now : nil
  end
end
