class BatchApplicant < ApplicationRecord
  include Taggable
  include PrivateFilenameRetrievable

  PAYMENT_METHOD_HARDSHIP_SCHOLARSHIP = -'Hardship Scholarship'
  PAYMENT_METHOD_POSTPAID_FEE = -'Postpaid Fee'
  PAYMENT_METHOD_REGULAR_FEE = -'Regular Fee'
  PAYMENT_METHOD_MERIT_SCHOLARSHIP = -'Merit Scholarship'
  REQUIRES_INCOME_PROOF = [PAYMENT_METHOD_POSTPAID_FEE, PAYMENT_METHOD_HARDSHIP_SCHOLARSHIP].freeze
  FEE_PAYMENT_METHODS = [PAYMENT_METHOD_REGULAR_FEE, PAYMENT_METHOD_POSTPAID_FEE, PAYMENT_METHOD_HARDSHIP_SCHOLARSHIP, PAYMENT_METHOD_MERIT_SCHOLARSHIP].freeze
  ID_PROOF_TYPES = ['Aadhaar Card', 'Driving License', 'Passport', 'Voters ID'].freeze

  has_many :applications_as_team_lead, class_name: 'BatchApplication', foreign_key: 'team_lead_id', dependent: :restrict_with_error
  has_and_belongs_to_many :batch_applications
  has_many :payments
  belongs_to :college
  belongs_to :user
  belongs_to :founder, optional: true

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

  scope :with_email, -> (email) { where('lower(email) = ?', email.downcase) }

  # Basic validations.
  validates :email, presence: true, uniqueness: true, email: true
  validates :phone, mobile_number: true, allow_nil: true
  validates :fee_payment_method, inclusion: { in: FEE_PAYMENT_METHODS }, allow_nil: true
  validates :id_proof_type, inclusion: { in: ID_PROOF_TYPES }, allow_nil: true

  normalize_attribute :gender, :reference, :phone, :fee_payment_method, :id_proof_type

  mount_uploader :id_proof, BatchApplicantDocumentUploader
  mount_uploader :address_proof, BatchApplicantDocumentUploader
  mount_uploader :income_proof, BatchApplicantDocumentUploader
  mount_uploader :letter_from_parent, BatchApplicantDocumentUploader

  def applied_to?(batch)
    return false unless batch_applications.present?

    batch_applications.find_by(batch_id: batch.id).present?
  end

  def self.reference_sources
    ['Friend', 'Seniors', '#StartinCollege Event', 'Newspaper/Magazine',
     'TV', 'SV.CO Blog', 'Instagram', 'Facebook', 'Twitter', 'Microsoft Student Partner',
     'Other (Please Specify)']
  end

  def multiple_applications?
    batch_applications.count > 1
  end

  def profile_complete?
    required_fields = [:name, :role, :born_on, :gender, :parent_name, :current_address, :permanent_address, :address_proof, :phone, :id_proof_type, :id_proof_number, :id_proof]
    required_fields += [:income_proof, :letter_from_parent, :college_contact] if income_proofs_required?

    required_fields.all? { |field| self[field].present? }
  end

  def income_proofs_required?
    fee_payment_method.in?(REQUIRES_INCOME_PROOF)
  end
end
