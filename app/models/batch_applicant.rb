class BatchApplicant < ActiveRecord::Base
  include Taggable

  has_and_belongs_to_many :batch_applications

  scope :team_leads, -> { joins(:batch_applications).where('batch_applications.team_lead_id = batch_applicants.id') }

  # Per-founder application fee.
  APPLICATION_FEE = 1000

  # Basic validations.
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  # Custom validations.
  validate :email_must_look_right

  def email_must_look_right
    errors[:email] << "doesn't look like an email" unless email =~ /\S+@\S+/
  end

  validate :phone_must_look_right

  def phone_must_look_right
    return if phone.blank?
    errors[:phone] << 'must be a 10-digit mobile phone number' unless phone =~ /^[0-9]{10}$/
  end

  has_secure_token

  normalize_attribute :phone, with: :phone
  normalize_attribute :gender, with: :blank

  # Attempts to find an applicant with the supplied token.
  def self.find_using_token(incoming_token)
    applicant = find_by token: incoming_token

    return if applicant.blank?

    # Hack to continue logins that were created before time-bound check was introduced.
    applicant.update!(sign_in_email_sent_at: Time.now) if applicant.sign_in_email_sent_at.blank?

    # Don't sign in applicant if the email was sent over an hour ago.
    return if applicant.sign_in_email_sent_at < 1.hour.ago

    applicant
  end

  def applied_to?(batch)
    return false unless batch_applications.present?

    batch_applications.find_by(batch_id: batch.id).present?
  end

  def send_sign_in_email(application_batch)
    # Create a new token.
    regenerate_token

    # Send email.
    BatchApplicantMailer.sign_in(email, token, application_batch).deliver_now

    # Mark when email was sent.
    update!(sign_in_email_sent_at: Time.now)
  end
end
