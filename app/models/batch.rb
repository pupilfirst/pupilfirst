class Batch < ApplicationRecord
  has_many :startups
  has_many :founders, through: :startups
  has_many :application_rounds, dependent: :destroy
  has_many :batch_applications, through: :application_rounds
  has_many :batch_applicants, through: :batch_applications
  has_many :program_weeks
  has_many :target_groups, through: :program_weeks
  has_many :targets, through: :program_weeks

  scope :live, -> { where('start_date <= ? and end_date >= ?', Time.now, Time.now) }
  scope :not_completed, -> { where('end_date >= ?', Time.now) }

  scope :open_for_applications, lambda {
    joins(:application_rounds).merge(ApplicationRound.open_for_applications)
  }

  scope :ongoing_applications, lambda {
    joins(application_rounds: :round_stages)
      .where(round_stages: { application_stage_id: ApplicationStage.final_stage })
      .where('round_stages.starts_at > ?', Time.now)
  }

  # Batches that opened for applications at some point of time in the past.
  scope :opened_for_applications, -> { joins(:application_rounds).distinct }

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

  def present_week_number
    return nil unless (start_date - 1.day).past?
    ((Date.today - start_date).to_f / 7).ceil
  end
end
