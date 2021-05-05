class CreateSubmissionMutator < ApplicationQuery
  include AuthorizeStudent
  include LevelUpEligibilityComputable

  property :target_id, validates: { presence: { message: 'BlankTargetId' } }
  property :checklist
  property :file_ids

  validate :all_files_should_be_new
  validate :maximum_three_attachments_per_item
  validate :ensure_submittability
  validate :attempted_minimum_questions
  validate :valid_response
  validate :valid_file_ids_in_checklist

  def all_files_should_be_new
    return if timeline_event_files.where.not(timeline_event_id: nil).empty?

    errors[:base] << 'Some file attachments have already been linked to a submission'
  end

  def maximum_three_attachments_per_item
    return if file_items.select { |item| item['result'].split.flatten.length > 3 }.empty?

    errors[:base] << 'No more than three files can be attached to a submission item'
  end

  def valid_file_ids_in_checklist
    return if file_ids.blank?

    return if file_items.map { |item| item['result'] }.flatten.sort == file_ids.sort

    errors[:base] << 'some files attached are invalid'
  end

  def ensure_submittability
    submittable = target.evaluation_criteria.exists?
    submission_required = target_status.in?([Targets::StatusService::STATUS_PENDING, Targets::StatusService::STATUS_FAILED])
    submitted_but_resubmittable = target.resubmittable? && target_status == Targets::StatusService::STATUS_PASSED

    return if submittable && (submission_required || submitted_but_resubmittable)

    errors[:base] << "The status of this target is '#{target_status}', so you cannot add a new submission; please reload the page"
  end

  def create_submission
    TimelineEvent.transaction do
      params = {
        target: target,
        checklist: checklist
      }

      timeline_event = TimelineEvents::CreateService.new(params, student).execute

      timeline_event_files.each do |timeline_event_file|
        timeline_event_file.update!(timeline_event: timeline_event) if file_ids.any?
      end

      timeline_event
    end
  end

  private

  def file_items
    @file_items ||= checklist.select { |item| item['kind'] == 'files' || 'audio' }
  end

  def valid_response
    return if checklist.respond_to?(:all?) && checklist.all? do |item|
      item['title'].is_a?(String) && item['kind'].in?(Target.valid_checklist_kind_types) &&
        item['status'] == TimelineEvent::CHECKLIST_STATUS_NO_ANSWER && item['result'].present? &&
        valid_result(item['kind'], item['result'])
    end

    errors[:base] << 'Submission checklist is not valid.'
  end

  def valid_result(kind, result)
    case kind
    when Target::CHECKLIST_KIND_FILES
      (result - file_ids).empty?
    when Target::CHECKLIST_KIND_AUDIO
      (result.split - file_ids).empty?
    when Target::CHECKLIST_KIND_LINK
      result.length >= 3 && result.length <= 2048
    when Target::CHECKLIST_KIND_LONG_TEXT
      result.length >= 1 && result.length <= 10_000
    when Target::CHECKLIST_KIND_MULTI_CHOICE, Target::CHECKLIST_KIND_SHORT_TEXT
      result.length >= 1 && result.length <= 500
    else
      false
    end
  end

  def attempted_minimum_questions
    target.checklist.each do |c|
      next if c['optional'] == true

      item = checklist.select { |i| i["title"] == c['title'] }

      next if item.present? && item.count == 1 && item.first['result'].present?

      errors[:base] << "Missing answer for question: #{c['title']}"
    end
  end

  def timeline_event_files
    TimelineEventFile.where(id: file_ids)
  end
end
