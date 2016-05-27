class Batch < ActiveRecord::Base
  has_many :startups
  has_many :founders, through: :startups
  has_many :batch_applications
  belongs_to :application_stage

  scope :live, -> { where('start_date <= ? and end_date >= ?', Time.now, Time.now) }
  scope :not_completed, -> { where('end_date >= ?', Time.now) }

  just_define_datetime_picker :application_stage_deadline

  validates :name, presence: true, uniqueness: true
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

  def to_label
    "##{batch_number} #{name}"
  end

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
end
