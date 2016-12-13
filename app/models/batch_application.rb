class BatchApplication < ApplicationRecord
  include Taggable
  include PrivateFilenameRetrievable

  APPLICATION_FEE = 3000
  COURSE_FEE = 37_500

  belongs_to :batch
  belongs_to :application_stage
  has_many :application_submissions, dependent: :destroy
  has_and_belongs_to_many :batch_applicants
  accepts_nested_attributes_for :batch_applicants
  has_one :college, through: :team_lead
  belongs_to :team_lead, class_name: 'BatchApplicant'
  belongs_to :university
  has_one :payment, dependent: :restrict_with_error
  has_many :archived_payments, class_name: 'Payment', foreign_key: 'original_batch_application_id'
  belongs_to :startup, optional: true

  scope :selected, -> { joins(:application_stage).where(application_stages: { final_stage: true }) }

  # Batch applicants who haven't initiated payment yet.
  scope :submitted_application, -> { joins('LEFT OUTER JOIN payments on batch_applications.id = payments.batch_application_id').where(payments: { id: nil }) }

  # Batch applicants who have initiated payment, but haven't completed it.
  scope :payment_initiated, -> { joins(:payment).merge(Payment.requested) }

  # Batch applicants who have completed payment.
  scope :payment_complete, -> { joins(:payment).merge(Payment.paid) }

  scope :paid_today, -> { payment_complete.where('payments.paid_at > ?', Time.now.in_time_zone('Asia/Kolkata').beginning_of_day) }
  scope :payment_initiated_today, -> { payment_initiated.where('payments.created_at > ?', Time.now.in_time_zone('Asia/Kolkata').beginning_of_day) }

  scope :from_state, -> (state) { joins(:college).where(colleges: { state_id: state.id }) }
  scope :from_other_states, -> { joins(:college).where.not(colleges: { state_id: State.focused_for_admissions.pluck(:id) }) }

  # a single scope for states - specify a State or :non_focused or :all.
  def self.for_states(scope)
    raise 'Unexpected Argument. Must be a State or :non_focused or :all' unless scope.is_a?(State) || scope.in?([:non_focused, :all])

    if scope.is_a?(State)
      joins(:college).where(colleges: { state_id: scope.id })
    elsif scope == :non_focused
      joins(:college).where.not(colleges: { state_id: State.focused_for_admissions.pluck(:id) })
    elsif scope == :all
      all
    end
  end

  mount_uploader :partnership_deed, BatchApplicantDocumentUploader

  validates :batch_id, presence: true
  validates :application_stage_id, presence: true

  delegate :batch_number, to: :batch

  # If a team lead is present (should be), display his name and batch number as title, otherwise use this entry's ID.
  def display_name
    if team_lead.present?
      if batch.present?
        "#{team_lead&.name} (#{batch.name})"
      else
        "#{team_lead&.name} (Batch Pending)"
      end
    else
      "Batch Application ##{id}"
    end
  end

  # Batch application's score is current stage's submission's score.
  def score
    application_submissions.find_by(application_stage_id: application_stage.id)&.score
  end

  # Promotes this application to the next stage, and returns the latest stage.
  def promote!(force: false)
    if promotable? || force
      self.application_stage = application_stage.next
      save!
    end

    application_stage
  end

  # Application is promotable if its stage has started (except if it's in the final stage).
  def promotable?
    return false if application_stage.final_stage?
    batch.stage_started?(application_stage)
  end

  # Returns true if application is in interview stage.
  def interviewable?
    return false if batch.blank?
    interview_stage = ApplicationStage.interview_stage

    # Not if already interviewed
    return false if application_submissions.find_by(application_stage: interview_stage).present?

    # Must be in interview stage
    application_stage == interview_stage
  end

  def cofounders
    batch_applicants.where.not(id: team_lead_id)
  end

  # Fee amount, calculated from unpaid founders
  def fee
    APPLICATION_FEE
  end

  # Batch application is paid depending on its payment request status.
  def paid?
    return false if payment.blank?
    payment.paid?
  end

  # Called after payment is known to have succeeded. This automatically promotes stage 1 applications to stage 2.
  def perform_post_payment_tasks!
    promote!(force: true) if application_stage.initial_stage?
  end

  # Destroys all trace of an application so that applicant can start again.
  def restart!
    raise 'Paid payment is present!' if paid?
    raise "Restart blocked because application is in stage #{application_stage.number}" unless application_stage.initial_stage?

    # Destroy payment if it exists.
    if payment.present?
      payment.archive!
      reload
    end

    # Destory self.
    destroy!
  end

  # Returns either a completed Payment (Stage 1), or ApplicationSubmission (any other stage), or nil
  def submission
    if application_stage.initial_stage?
      payment.present? && payment.paid? ? payment : nil
    else
      application_submissions.find_by(application_stage: application_stage)
    end
  end

  # Returns true if application has been upgraded to a stage that is currently not active.
  def promoted?
    !batch.stage_active?(application_stage) && !batch.stage_expired?(application_stage)
  end

  # Returns true if the application is in an active stage and hasn't submitted.
  def ongoing?
    batch.stage_active?(application_stage) && submission.blank?
  end

  # Returns true application has a submission for current stage.
  def submitted?
    submission.present? && !batch.stage_started?(application_stage.next)
  end

  # Returns true if stage has expired and there's no submssion.
  def expired?
    batch.stage_expired?(application_stage) && submission.blank?
  end

  # Returns true if application's stage has expired, there's a submission, and the next stage has started.
  def rejected?
    batch.stage_expired?(application_stage) && batch.stage_started?(application_stage.next) && submission.present?
  end

  # Returns one of :ongoing, :submitted, :expired, :promoted, :rejected, or :complete
  def status
    if ongoing?
      :ongoing
    elsif submitted?
      :submitted
    elsif expired?
      :expired
    elsif promoted?
      :promoted
    elsif rejected?
      :rejected
    else
      raise "BatchApplication ##{id} is in an unexpected state. Please investigate."
    end
  end

  # An application that has submitted for stage 2, or beyond merits a certificate from SV.CO
  def merits_certificate?
    return true if application_stage.number > 2
    return false if application_stage.number == 1

    # If application is at stage 2, :rejected state gets certificate, and :expired does not.
    status == :rejected
  end

  # Returns name of states with most number of applications - excludes 'Other' if present
  # this was included to dynamically calculate the top states for Admissions Dashboard. Later replaced by the pre-selected list of states i.e State.focused_for_admissions
  def self.top_states(n)
    joins(:university).group(:location).count.sort_by { |_k, v| v }.reverse[0..(n - 1)].to_h.keys - ['Other']
  end

  # Returns applicant eligible for receiving refund of the application fee. This refund is to be applied on the course fee.
  def applicant_eligible_for_refund
    if team_lead.fee_payment_method == BatchApplicant::PAYMENT_METHOD_REGULAR_FEE
      team_lead
    else
      cofounders.order('name ASC').where(fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE).first
    end
  end

  # Returns remaining course fee for a given applicant.
  def applicant_course_fee(batch_applicant)
    raise "BatchApplicant##{batch_applicant.id} does not belong BatchApplication##{id}" unless batch_applicants.include?(batch_applicant)

    refund_amount = payment&.refunded? ? 0 : payment&.amount.to_i

    if refund_amount.positive? && batch_applicant == applicant_eligible_for_refund
      COURSE_FEE - refund_amount
    elsif batch_applicant.fee_payment_method == BatchApplicant::PAYMENT_METHOD_REGULAR_FEE
      COURSE_FEE
    else
      0
    end
  end

  # Need to iterate over applicants since each could have different payment method.
  def total_course_fee
    batch_applicants.map { |applicant| applicant_course_fee(applicant) }.sum
  end
end
