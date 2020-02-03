class CreateSubmissionMutator < ApplicationQuery
  include AuthorizeStudent

  property :target_id, validates: { presence: { message: 'BlankTargetId' } }
  property :description, validates: { presence: { message: 'BlankDescription' }, length: { maximum: 1500, minimum: 1, message: 'InvalidDescriptionLength' } }
  property :links, validates: { urls: true }
  property :file_ids

  validate :all_files_should_be_new
  validate :maximum_three_attachments
  validate :ensure_submittability

  def all_files_should_be_new
    return if timeline_event_files.where.not(timeline_event_id: nil).empty?

    errors[:base] << 'Some file attachments have already been linked to a submission'
  end

  def maximum_three_attachments
    return if (file_ids.count + links.count) <= 3

    errors[:base] << 'TooManyAttachments'
  end

  def ensure_submittability
    submittable = target.evaluation_criteria.exists?
    submission_required = target_status.in?([Targets::StatusService::STATUS_PENDING, Targets::StatusService::STATUS_FAILED])
    submitted_but_resubmittable = target.resubmittable? && target_status == Targets::StatusService::STATUS_PASSED

    return if submittable && (submission_required || submitted_but_resubmittable)

    errors[:base] << "NotSubmittable(#{target_status})"
  end

  def create_submission
    TimelineEvent.transaction do
      params = {
        target: target,
        description: description.strip,
        links: links
      }

      timeline_event = TimelineEvents::CreateService.new(params, founder).execute

      timeline_event_files.each do |timeline_event_file|
        timeline_event_file.update!(timeline_event: timeline_event) if file_ids.any?
      end

      TimelineEvents::AfterFounderSubmitJob.perform_later(timeline_event)

      timeline_event
    end
  end

  private

  def timeline_event_files
    TimelineEventFile.where(id: file_ids)
  end
end
