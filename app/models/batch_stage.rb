class BatchStage < ActiveRecord::Base
  belongs_to :batch
  belongs_to :application_stage

  validates_uniqueness_of :application_stage_id, scope: [:batch_id]

  validates :starts_at, presence: true
  validates :ends_at, presence: true, unless: proc { |batch_stage| !!batch_stage.application_stage&.final_stage? }

  validate :should_start_before_end

  just_define_datetime_picker :starts_at
  just_define_datetime_picker :ends_at

  def should_start_before_end
    return if ends_at.blank? || starts_at.blank?
    return if ends_at > starts_at
    errors[:stars_at] << 'should be before end date'
    errors[:ends] << 'should be after start date'
  end

  def active?
    starts_at < Time.now && ends_at > Time.now
  end
end
