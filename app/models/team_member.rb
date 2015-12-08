class TeamMember < ActiveRecord::Base
  belongs_to :startup

  mount_uploader :avatar, AvatarUploader
  process_in_background :avatar

  include Gravtastic
  gravtastic

  serialize :roles

  before_validation do
    # Remove blank roles, if any.
    roles.delete('')
  end

  validate :roles_must_be_valid

  def roles_must_be_valid
    if roles.blank?
      errors.add(:roles, 'pick at least one')
      return
    elsif roles.count > 2
      errors.add(:roles, 'pick no more than two')
      return
    end

    roles.each do |role|
      unless User.valid_roles.include? role
        errors.add(:roles, 'contained unrecognized value')
      end
    end
  end

  def roles
    super || []
  end

  validates_presence_of :startup_id, :name
end
