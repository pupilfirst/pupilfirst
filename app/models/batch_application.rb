class BatchApplication < ActiveRecord::Base
  include Taggable

  FEE = 3000

  belongs_to :batch
  belongs_to :application_stage
  has_many :application_submissions, dependent: :destroy
  has_and_belongs_to_many :batch_applicants
  has_one :college, through: :team_lead
  belongs_to :team_lead, class_name: 'BatchApplicant'
  belongs_to :university
  has_one :payment, dependent: :restrict_with_error
  has_many :archived_payments, class_name: 'Payment', foreign_key: 'original_batch_application_id'

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

  validates :batch_id, presence: true
  validates :application_stage_id, presence: true

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
  def promote!
    if promotable?
      self.application_stage = application_stage.next
      save!
    end

    application_stage
  end

  # Application is promotable if its stage has started.
  def promotable?
    batch.stage_started?(application_stage)
  end

  def cofounders
    batch_applicants.where.not(id: team_lead_id)
  end

  # Fee amount, calculated from unpaid founders
  def fee
    FEE
  end

  # Batch application is paid depending on its payment request status.
  def paid?
    return false if payment.blank?
    payment.paid?
  end

  def invite_applicants!
    # create unique tokens using time and id
    startup_token = Time.now.in_time_zone('Asia/Calcutta').strftime('%a, %e %b %Y, %I:%M:%S %p IST') + " ID#{id}"

    Founder.transaction do
      # Invite team lead.
      Founder.invite! email: team_lead.email, invited_batch: batch, startup_token: startup_token, startup_admin: true

      # Invite cofounders one by one.
      cofounders.each do |cofounder|
        Founder.invite! email: cofounder.email, invited_batch: batch, startup_token: startup_token
      end
    end
  end

  # Called after payment is known to have succeeded. This automatically promotes stage 1 applications to stage 2.
  def perform_post_payment_tasks!
    promote! if application_stage.initial_stage?
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

  # Returns true if the application is in the final stage.
  def complete?
    application_stage == ApplicationStage.final_stage
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
  #
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
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
    elsif complete?
      :complete
    else
      raise "BatchApplication ##{id} is in an unexpected state. Please investigate."
    end
  end

  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # Creates a duplicate (pristine, unpaid) of this application into given batch.
  def duplicate!(batch)
    application = BatchApplication.create!(
      batch: batch,
      team_lead: team_lead,
      application_stage: ApplicationStage.initial_stage,
      university: university,
      college: college,
      team_size: team_size
    )

    application.batch_applicants << team_lead

    update!(swept_at: Time.now)

    # Send email to the lead.
    BatchApplicantMailer.swept(team_lead, batch).deliver_later
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
end
