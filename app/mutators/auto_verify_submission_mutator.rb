class AutoVerifySubmissionMutator < ApplicationMutator
  include AuthorizeFounder

  attr_accessor :target_id

  validates :target_id, presence: { message: 'Blank Target Id' }
  validate :can_be_auto_verified
  validate :can_be_submitted

  def can_be_auto_verified
    return if target.evaluation_criteria.blank? && target.quiz.blank?

    errors[:base] << 'The target cannot be auto verified'
  end

  def can_be_submitted
    return if founder.timeline_events.where(target_id: target_id).blank?

    errors[:base] << 'You cannot resubmit the target'
  end

  def create_submission
    target.timeline_events.create!(
      founders: founders,
      description: description,
      passed_at: Time.zone.now,
      latest: true
    )
  end

  private

  def founder
    @founder ||= current_user.founders.joins(:level).where(levels: { course_id: course }).first
  end

  def course
    @course ||= target.course
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end

  def startup
    @startup ||= founder.startup
  end

  def description
    "Target '#{target.title}' was automatically marked complete."
  end

  def founders
    if target.founder_event?
      [founder]
    else
      founder.startup.founders
    end
  end
end
