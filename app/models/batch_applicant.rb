class BatchApplicant < ActiveRecord::Base
  has_and_belongs_to_many :batch_applications
  has_and_belongs_to_many :payments
  has_many :applications_as_lead, class_name: 'BatchApplication', foreign_key: 'team_lead_id'

  # Per-founder application fee.
  APPLICATION_FEE = 2500
  NUMBER_OF_APPLICATIONS_PER_FEE = 4

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

  # A fee is required is applicant is not eligible to submit any applications.
  def fee_required?
    applications_left <= 0
  end

  # Returns number of applications this applicant is eligible to create.
  def applications_left
    (credited_payments.count * NUMBER_OF_APPLICATIONS_PER_FEE) - considered_applications.count
  end

  # Applications that moved beyond stage 1.
  def considered_applications
    batch_applications.joins(:application_stage).where('application_stages.number > ?', 1)
  end

  # Payment requests made for this applicant that have been 'paid'.
  def credited_payments
    payments.where(instamojo_payment_status: Instamojo::PAYMENT_STATUS_CREDITED)
  end
end
