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

  # Attempts to find an applicant with the supplied token. If found, the token is regenerated to invalidate previous
  # value, thus preventing reuse of login link.
  def self.find_using_token(incoming_token)
    applicant = find_by token: incoming_token
    return if applicant.blank?
    applicant.regenerate_token
    applicant
  end

  def applied_to?(batch)
    return false unless batch_applications.present?

    batch_applications.find_by(batch_id: batch.id).present?
  end
end
