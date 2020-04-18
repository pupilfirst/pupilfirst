class AutoVerifySubmissionMutator < ApplicationQuery
  include AuthorizeStudent

  property :target_id, validates: { presence: { message: 'Blank Target Id' } }

  validate :can_be_auto_verified
  validate :ensure_submittability

  def create_submission
    submission = target.timeline_events.create!(
      founders: founders,
      passed_at: Time.zone.now,
      latest: true
    )

    TimelineEvents::AfterMarkingAsCompleteJob.perform_later(submission)

    submission
  end

  private

  def can_be_auto_verified
    return if target.evaluation_criteria.empty? && target.quiz.blank?

    errors[:base] << 'The target cannot be auto verified'
  end
end
