class CreateSubmissionMutator < ApplicationMutator
  include AuthorizeStudent

  attr_accessor :target_id
  attr_accessor :description
  attr_accessor :links
  attr_accessor :file_ids

  validates :target_id, presence: { message: 'BlankTargetId' }
  validates :description, presence: { message: 'BlankDescription' }, length: { maximum: 1500, minimum: 1, message: 'InvalidDescriptionLength' }

  validate :no_pending_submission_already
  validate :all_files_should_be_new

  def no_pending_submission_already
    return if founder.timeline_events.where(target_id: target_id).pending_review.empty?

    errors[:base] << 'You already have a submission that is pending review'
  end

  def all_files_should_be_new
    return if timeline_event_files.where.not(timeline_event_id: nil).empty?

    errors[:base] << 'File attachments have already been linked to a submission'
  end

  def create_submission
    TimelineEvent.transaction do
      timeline_event = target.timeline_events.create!(
        founders: founders,
        description: description,
        quiz_score: result[:score],
        passed_at: Time.zone.now,
        latest: true
      )

      timeline_event_files.update!(timeline_event: timeline_event) if file_ids.any?

      timeline_event
    end
  end

  private

  def timeline_event_files
    TimelineEventFile.where(id: file_ids)
  end
end
