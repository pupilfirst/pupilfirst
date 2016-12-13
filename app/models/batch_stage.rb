class BatchStage < ApplicationRecord
  belongs_to :batch
  belongs_to :application_stage

  validates :application_stage_id, uniqueness: { scope: [:batch_id] }
  validates :starts_at, presence: true

  # It is possible for BatchStage to be instantiated without application stage (an error captured by validation above),
  # but in order to handle that error, we should treat it as a possible case in this related validation.
  # rubocop:disable Style/DoubleNegation
  validates :ends_at, presence: true, unless: proc { |batch_stage| !!batch_stage.application_stage&.final_stage? }
  # rubocop:enable Style/DoubleNegation

  validate :should_start_before_end

  def should_start_before_end
    return if ends_at.blank? || starts_at.blank?
    return if ends_at > starts_at
    errors[:stars_at] << 'should be before end date'
    errors[:ends] << 'should be after start date'
  end

  def active?
    if application_stage.final_stage?
      starts_at < Time.now
    else
      starts_at < Time.now && ends_at > Time.now
    end
  end
end
