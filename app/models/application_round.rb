class ApplicationRound < ApplicationRecord
  belongs_to :batch
  has_many :round_stages, dependent: :destroy
  has_many :batch_applications, dependent: :restrict_with_error

  validates :batch, presence: true
  validates :number, presence: true

  accepts_nested_attributes_for :round_stages, allow_destroy: true

  scope :open_for_applications, lambda {
    joins(:round_stages)
      .where(round_stages: { application_stage_id: ApplicationStage.initial_stage })
      .where('round_stages.starts_at < ?', Time.now)
      .where('round_stages.ends_at > ?', Time.now)
  }

  scope :opened_for_applications, lambda {
    joins(:round_stages)
      .where(round_stages: { application_stage_id: ApplicationStage.initial_stage })
      .where('round_stages.starts_at < ?', Time.now)
  }

  def display_name
    "Batch #{batch.batch_number} Round #{number}"
  end

  alias name display_name

  # Stage is active when current time is between its bounds.
  def stage_active?(stage)
    if stage.final_stage?
      round_stages.where(application_stage: stage)
        .where('starts_at < ?', Time.now).present?
    else
      round_stages.where(application_stage: stage)
        .where('starts_at < ?', Time.now)
        .where('ends_at > ?', Time.now).present?
    end
  end

  # Returns true if applications for this batch closes within 7 days.
  def closes_soon?
    initial_stage = ApplicationStage.initial_stage
    return false unless stage_active?(initial_stage)
    return false if round_stages.find_by(application_stage: initial_stage).ends_at > 7.days.from_now
    true
  end

  def stage_expired?(stage)
    round_stages.where(application_stage: stage).where('ends_at < ?', Time.now).present?
  end

  def stage_started?(stage)
    round_stages.where(application_stage: stage).where('starts_at < ?', Time.now).present?
  end

  def initial_stage?
    stage_active?(ApplicationStage.initial_stage)
  end

  def final_stage?
    stage_started?(ApplicationStage.final_stage)
  end

  # Currently 'open' round - the one which is accepting new applications.
  def self.open_round
    open_for_applications.first if open_for_applications.any?
  end

  def admission_close_at
    round_stages&.find_by(application_stage_id: ApplicationStage.initial_stage)&.ends_at
  end

  def campaign_days_passed
    return 0 if Time.now < campaign_start_at

    (Date.today - campaign_start_at.to_date).to_i
  end

  def campaign_days_left
    return 0 if Time.now > admission_close_at

    (admission_close_at.to_date - Date.today).to_i
  end

  def total_campaign_days
    (admission_close_at.to_date - campaign_start_at.to_date).to_i
  end
end
