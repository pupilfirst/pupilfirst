class Target < ActiveRecord::Base
  belongs_to :startup
  belongs_to :assigner, class_name: 'AdminUser'

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

  before_save do
    self.completed_at = (status_changed? && done?) ? completed_at || Time.now : nil
  end
end
