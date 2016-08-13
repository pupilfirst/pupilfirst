class Batch < ActiveRecord::Base
  has_many :startups
  has_many :founders, through: :startups
  has_many :batch_applications
  has_many :batch_stages, dependent: :destroy

  accepts_nested_attributes_for :batch_stages, allow_destroy: true

  scope :live, -> { where('start_date <= ? and end_date >= ?', Time.now, Time.now) }
  scope :not_completed, -> { where('end_date >= ?', Time.now) }

  scope :open_for_applications, lambda {
    joins(:batch_stages)
      .where(batch_stages: { application_stage_id: ApplicationStage.initial_stage })
      .where('batch_stages.starts_at < ?', Time.now)
      .where('batch_stages.ends_at > ?', Time.now)
  }

  validates :theme, presence: true
  validates :batch_number, presence: true, numericality: true, uniqueness: true
  validates_presence_of :start_date, :end_date
  validates :slack_channel,
    format: { with: /#[^A-Z\s.;!?]+/, message: 'must start with a # and not contain uppercase, spaces or periods' },
    length: { in: 2..22, message: 'channel name should be 1-21 characters' }, allow_nil: true

  # after_save :send_emails_to_applicants
  #
  # def send_emails_to_applicants
  #   return unless application_stage_id_changed?
  #   return if application_stage.initial_stage? || application_stage.final_stage?
  #
  #   EmailApplicantsJob.perform_later(self)
  # end

  def display_name
    "##{batch_number} #{theme}"
  end

  alias name display_name

  # TODO: Batch.current should probably be re-written to account for overlapping batches.
  def self.current
    where('start_date <= ? and end_date >= ?', Time.now, Time.now).first
  end

  # If the current batch isn't present, supply last.
  def self.current_or_last
    current.present? ? current : last
  end

  # Probably use this to auto-announce results
  def selected_team_leads
    BatchApplicant.find selected_applications.pluck(:team_lead_id)
  end

  def selected_applications
    batch_applications.selected
  end

  def invite_selected_candidates!
    Batch.transaction do
      selected_applications.each(&:invite_applicants!)
      update!(invites_sent_at: Time.now)
    end
  end

  def invites_sent?
    invites_sent_at.present?
  end

  # Returns true if applications for this batch closes within 7 days.
  def applications_close_soon?
    initial_stage = ApplicationStage.initial_stage
    return false unless stage_active?(initial_stage)
    return false if batch_stages.find_by(application_stage: initial_stage).ends_at > 7.days.from_now
    true
  end

  # Currently 'open' batch - the one which is accepting new applications.
  def self.open_batch
    open_for_applications.first if open_for_applications.any?
  end

  # Stage is active when current time is between its bounds.
  def stage_active?(stage)
    batch_stages.where(application_stage: stage)
      .where('starts_at < ?', Time.now)
      .where('ends_at > ?', Time.now).present?
  end

  # Stage has expired when deadline has been crossed.
  def stage_expired?(stage)
    batch_stages.where(application_stage: stage).where('ends_at < ?', Time.now).present?
  end

  def stage_started?(stage)
    batch_stages.where(application_stage: stage).where('starts_at < ?', Time.now).present?
  end

  def applications_complete?
    stage_started?(ApplicationStage.final_stage)
  end
end
