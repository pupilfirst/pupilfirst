class BatchApplicant < ApplicationRecord
  include Taggable

  FEE_PAYMENT_METHODS = ['Regular Fee', 'Postpaid Fee', 'Hardship Scholarship', 'Merit Scholarship'].freeze

  has_many :applications_as_team_lead, class_name: 'BatchApplication', foreign_key: 'team_lead_id', dependent: :restrict_with_error
  has_and_belongs_to_many :batch_applications
  has_many :payments
  belongs_to :college

  attr_accessor :reference_text

  accepts_nested_attributes_for :college

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

  scope :for_batch_id_in, -> (ids) { joins(:batch_applications).where(batch_applications: { batch_id: ids }) }

  # Basic validations.
  validates :email, presence: true, uniqueness: true, email: true
  validates :phone, mobile_number: true
  validates_inclusion_of :fee_payment_method, in: FEE_PAYMENT_METHODS, allow_nil: true

  has_secure_token

  normalize_attribute :gender, :reference, :phone, :fee_payment_method

  def applied_to?(batch)
    return false unless batch_applications.present?

    batch_applications.find_by(batch_id: batch.id).present?
  end

  def send_sign_in_email(shared_device: false, defer: false)
    # Send email.
    mailer = BatchApplicantMailer.sign_in(self, shared_device)
    defer ? mailer.deliver_later : mailer.deliver_now

    # Mark when email was sent.
    update!(sign_in_email_sent_at: Time.now)
  end

  def self.reference_sources
    ['Friend', 'Seniors', '#StartinCollege Event', 'Newspaper/Magazine',
     'TV', 'SV.CO Blog', 'Instagram', 'Facebook', 'Twitter', 'Microsoft Student Partner',
     'Other (Please Specify)']
  end

  def multiple_applications?
    batch_applications.count > 1
  end
end
