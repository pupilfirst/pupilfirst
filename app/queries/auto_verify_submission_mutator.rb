class AutoVerifySubmissionMutator < ApplicationQuery
  include AuthorizeStudent
  include DevelopersNotifications

  property :target_id, validates: { presence: { message: 'Blank Target Id' } }

  validate :can_be_auto_verified
  validate :ensure_submittability

  def create_submission
    submission =
      TimelineEvent.transaction do
        TimelineEvent
          .create!(target: target, passed_at: Time.zone.now)
          .tap do |submission|
            students.map do |student|
              student.timeline_event_owners.create!(
                timeline_event: submission,
                latest: true
              )
            end
          end
      end

    TimelineEvents::AfterMarkingAsCompleteJob.perform_later(submission)
    publish(
      course,
      :submission_automatically_verified,
      current_user,
      submission
    )

    submission
  end

  private

  def can_be_auto_verified
    return if target.evaluation_criteria.empty? && target.quiz.blank?

    errors.add(:base, 'The target cannot be auto verified')
  end
end
