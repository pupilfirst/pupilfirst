class BatchApplicant < ActiveRecord::Base
  has_and_belongs_to_many :batch_applications
  has_many :applications_as_lead, class_name: 'BatchApplication', foreign_key: 'team_lead_id'

  # Basic validations.
  validates :email, presence: true, uniqueness: true

  # Custom validations.
  validate :email_must_look_right

  def email_must_look_right
    errors[:email] << "doesn't look like an email" unless email =~ /\S+@\S+/
  end

  has_secure_token
end
