class Batch < ApplicationRecord
  has_many :startups
  has_many :founders, through: :startups
  has_many :batch_applications
  has_many :batch_applicants, through: :batch_applications
  has_many :batch_stages, dependent: :destroy
  has_many :targets
  has_many :program_weeks
  has_many :target_groups, through: :program_weeks

  accepts_nested_attributes_for :batch_stages, allow_destroy: true

  scope :live, -> { where('start_date <= ? and end_date >= ?', Time.now, Time.now) }
  scope :not_completed, -> { where('end_date >= ?', Time.now) }

  scope :open_for_applications, lambda {
    joins(:batch_stages)
      .where(batch_stages: { application_stage_id: ApplicationStage.initial_stage })
      .where('batch_stages.starts_at < ?', Time.now)
      .where('batch_stages.ends_at > ?', Time.now)
  }

  scope :ongoing_applications, lambda {
    joins(:batch_stages)
      .where(batch_stages: { application_stage_id: ApplicationStage.final_stage })
      .where('batch_stages.starts_at > ?', Time.now)
  }

  # Batches that opened for applications at some point of time in the past.
  scope :opened_for_applications, -> { joins(:batch_stages).distinct }

  validates :theme, presence: true
  validates :batch_number, presence: true, numericality: true, uniqueness: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :slack_channel, slack_channel_name: true, allow_nil: true
  validates :campaign_start_at, presence: true
  validates :target_application_count, presence: true

  def display_name
    "##{batch_number} #{theme}"
  end

  alias name display_name

  # TODO: Batch.current should probably be re-written to account for overlapping batches.
  def self.current
    find_by('start_date <= ? and end_date >= ?', Time.now, Time.now)
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
    if stage.final_stage?
      batch_stages.where(application_stage: stage)
        .where('starts_at < ?', Time.now).present?
    else
      batch_stages.where(application_stage: stage)
        .where('starts_at < ?', Time.now)
        .where('ends_at > ?', Time.now).present?
    end
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

  def initial_stage?
    stage_active?(ApplicationStage.initial_stage)
  end

  def final_stage?
    stage_started?(ApplicationStage.final_stage)
  end
end
