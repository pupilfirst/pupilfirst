class RoundStage < ApplicationRecord
  belongs_to :application_round
  belongs_to :application_stage

  validates :application_stage_id, uniqueness: { scope: [:application_round_id] }
  validates :starts_at, presence: true

  # It is possible for RoundStage to be instantiated without application stage (an error captured by validation above),
  # but in order to handle that error, we should treat it as a possible case in this related validation.
  validates :ends_at, presence: true, unless: proc { |round_stage| round_stage.application_stage.present? && round_stage.application_stage.final_stage? }

  validate :should_start_before_end

  def should_start_before_end
    return if ends_at.blank? || starts_at.blank?
    return if ends_at > starts_at
    errors[:stars_at] << 'should be before end date'
    errors[:ends] << 'should be after start date'
  end

  def active?
    if application_stage.final_stage?
      starts_at < Time.zone.now
    else
      starts_at < Time.zone.now && ends_at > Time.zone.now
    end
  end
end
