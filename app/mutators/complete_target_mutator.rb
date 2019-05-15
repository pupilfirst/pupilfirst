class CompleteTargetMutator < ApplicationMutator
  attr_accessor :target_id

  validates :target_id, presence: true

  validate :must_be_incomplete

  def complete_target
    Targets::AutoVerificationService.new(target, current_founder).auto_verify
  end

  private

  def must_be_incomplete
    return if current_founder.timeline_events.where(target: target).empty?

    errors[:base] << 'TargetAlreadyComplete'
  end

  def target
    @target ||= Target.live.find_by(id: target_id)
  end

  # Target must be non-reviewed and student must have access to target.
  def authorized?
    current_founder.present? && target.present? &&
      target.evaluation_criteria.blank? &&
      current_founder.course == target.course
  end
end
