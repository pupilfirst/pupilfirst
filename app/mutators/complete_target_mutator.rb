class CompleteTargetMutator < ApplicationMutator
  attr_accessor :target_id

  validates :target_id, presence: true

  validate :must_be_auto_complete_target
  validate :must_be_incomplete

  def complete_target
    Targets::AutoVerificationService.new(target, current_founder).auto_verify
  end

  private

  def must_be_auto_complete_target
    return if timeline_event.pending_review?

    errors[:base] << 'ReviewRequired'
  end

  def must_be_incomplete
    return if current_founder.timeline_events.where(target: target).empty?

    errors[:base] << 'TargetAlreadyComplete'
  end

  def target
    @target ||= Target.live.find_by(id: target_id)
  end

  # Founders who can access an un-reviewed target.
  def authorized?
    current_founder.present? && target.present? &&
      target.evaluation_criteria.blank? &&
      current_founder.course == target.course
  end
end
