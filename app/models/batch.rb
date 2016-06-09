class Batch < ActiveRecord::Base
  has_many :startups
  has_many :founders, through: :startups
  has_many :batch_applications
  belongs_to :application_stage

  scope :live, -> { where('start_date <= ? and end_date >= ?', Time.now, Time.now) }
  scope :not_completed, -> { where('end_date >= ?', Time.now) }
  scope :open_for_applications, -> { joins(:application_stage).where(application_stages: { number: 1 }) }
  scope :applications_ongoing, -> { joins(:application_stage).where('application_stages.number > 1').where('application_stages.final_stage IS NOT TRUE') }
  scope :with_recent_results, -> { joins(:application_stage).where(application_stages: { final_stage: true }).where('start_date > ?', 3.months.ago) }

  just_define_datetime_picker :application_stage_deadline

  validates :theme, presence: true
  validates :batch_number, presence: true, numericality: true, uniqueness: true
  validates_presence_of :start_date, :end_date
  validates :slack_channel, format: { with: /#[^A-Z\s.;!?]+/, message: 'must start with a # and not contain uppercase, spaces or periods' },
                            length: { in: 2..22, message: 'channel name should be 1-21 characters' }, allow_nil: true

  validate :deadline_changes_with_stage

  def deadline_changes_with_stage
    return unless application_stage_id_changed?
    return if application_stage_deadline_changed?
    return if application_stage.final_stage?
    errors[:application_stage_deadline] << 'must change with application stage'
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

  def selected_candidates
    BatchApplicant.find selected_applications.pluck(:team_lead_id)
  end

  def selected_applications
    batch_applications.selected
  end
end
