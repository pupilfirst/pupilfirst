class Target < ActiveRecord::Base
  belongs_to :startup

  # See en.yml's role
  def self.valid_roles
    %w(team) + User.valid_roles
  end

  # See en.yml's target.status
  def self.valid_statuses
    %w(pending in_progress completed)
  end

  validates_presence_of :startup_id, :role, :status, :title, :short_description, :resource_url
  validates_inclusion_of :role, in: valid_roles
  validates_inclusion_of :status, in: valid_statuses
end
