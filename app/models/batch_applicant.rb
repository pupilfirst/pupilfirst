class BatchApplicant < ActiveRecord::Base
  include Taggable

  has_and_belongs_to_many :batch_applications
  has_many :payments

  attr_accessor :reference_text

  # Applicants who have submitted application, but haven't clicked pay.
  scope :submitted_application, lambda {
    joins(:batch_applications).where('batch_applications.team_lead_id = batch_applicants.id')
      .where.not(id: joins(:payments).select(:id)).distinct
  }

  # Applicants who have applications who clicked the pay button but didn't pay.
  scope :payment_initiated, lambda {
    joins(:batch_applications).where('batch_applications.team_lead_id = batch_applicants.id').joins(batch_applications: :payment)
      .merge(Payment.requested).distinct
  }

  # Applicants who have completed payments.
  scope :conversion, lambda {
    joins(:batch_applications).where('batch_applications.team_lead_id = batch_applicants.id').joins(batch_applications: :payment)
      .merge(Payment.paid).distinct
  }

  # Basic validations.
  validates :email, presence: true, uniqueness: true

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

  normalize_attribute :phone, with: [:strip, :phone]
  normalize_attribute :gender, :reference

  def applied_to?(batch)
    return false unless batch_applications.present?

    batch_applications.find_by(batch_id: batch.id).present?
  end

  def send_sign_in_email(shared_device: false)
    # Send email.
    BatchApplicantMailer.sign_in(self, shared_device).deliver_now

    # Mark when email was sent.
    update!(sign_in_email_sent_at: Time.now)
  end

  def self.reference_sources
    ['Friend', 'SV.CO Blog', 'Facebook/Twitter', 'TV, newspaper etc.', 'Other (Please Specify)']
  end
end
