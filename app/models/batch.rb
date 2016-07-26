class Batch < ActiveRecord::Base
  has_many :startups
  has_many :founders, through: :startups
  has_many :batch_applications
  belongs_to :application_stage

  scope :live, -> { where('start_date <= ? and end_date >= ?', Time.now, Time.now) }
  scope :not_completed, -> { where('end_date >= ?', Time.now) }

  scope :open_for_applications, lambda {
    joins(:application_stage)
      .where('application_stages.number = 1 OR (application_stages.number = 2 AND application_stage_deadline > ?)', Time.now)
  }

  scope :applications_ongoing, lambda {
    joins(:application_stage)
      .where('application_stages.number > 1')
      .where('application_stages.final_stage IS NOT TRUE')
      .where('(NOT (application_stages.number = 2 AND application_stage_deadline > ?))', Time.now)
  }

  scope :with_recent_results, -> { joins(:application_stage).where(application_stages: { final_stage: true }).where('start_date > ?', 3.months.ago) }

  just_define_datetime_picker :application_stage_deadline

  validates :theme, presence: true
  validates :batch_number, presence: true, numericality: true, uniqueness: true
  validates_presence_of :start_date, :end_date
  validates :slack_channel, format: { with: /#[^A-Z\s.;!?]+/, message: 'must start with a # and not contain uppercase, spaces or periods' },
    length: { in: 2..22, message: 'channel name should be 1-21 characters' }, allow_nil: true

  validate :application_dates_changes_with_stage

  def application_dates_changes_with_stage
    return unless application_stage_id_changed?
    return if application_stage.final_stage?
    errors[:application_stage_deadline] << 'must change with application stage' unless application_stage_deadline_changed?
    errors[:next_stage_starts_on] << 'must change with application stage' unless next_stage_starts_on_changed?
  end

  after_save :send_emails_to_applicants

  def send_emails_to_applicants
    return unless application_stage_id_changed?
    return if application_stage.initial_stage? || application_stage.final_stage?

    EmailApplicantsJob.perform_later(self)
  end

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

  # Stage has expired when deadline has been crossed.
  def stage_expired?
    application_stage_deadline.past?
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
    return false if application_stage&.number != 2
    return false if application_stage_deadline > 7.days.from_now
    true
  end

  # Currently 'open' batch - the one which has an application process ongoing.
  def self.open_batch
    if open_for_applications.any?
      open_for_applications.first
    else
      applications_ongoing.first if applications_ongoing.any?
    end
  end
end
