class AutoVerifySubmissionMutator < ApplicationQuery
  include AuthorizeStudent
  include LevelUpEligibilityComputable

  property :target_id, validates: { presence: { message: 'Blank Target Id' } }

  validate :can_be_auto_verified
  validate :ensure_submittability

  def create_submission
    TimelineEvent.transaction do
      submission = TimelineEvent.create!(target: target, passed_at: Time.zone.now)

      students.map do |student|
        student.timeline_event_owners.create!(timeline_event: submission, latest: true)
      end

      TimelineEvents::AfterMarkingAsCompleteJob.perform_later(submission)

      submission
    end
  end

  private

  def can_be_auto_verified
    return if target.evaluation_criteria.empty? && target.quiz.blank?

    errors[:base] << 'The target cannot be auto verified'
  end
end
