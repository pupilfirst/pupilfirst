module ValidateStudentSubmission
  extend ActiveSupport::Concern

  class AllFilesAreNew < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      files = TimelineEventFile.where(id: value[:file_ids])

      return if files.where.not(timeline_event_id: nil).blank?

      I18n.t('mutations.create_submission.linked_file_exists_error')
    end
  end

  class MaximumThreeAttachmentsPerItem < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      return if value[:file_ids].blank?

      file_items =
        value[:checklist].filter do |item|
          (item['kind'] == 'files' || item['kind'] == 'audio')
        end

      if file_items.select do |item|
           item['result'].split.flatten.length > 3
         end.empty?
        return
      end

      I18n.t('mutations.create_submission.item_file_limit_error')
    end
  end

  class EnsureSubmittability < GraphQL::Schema::Validator
    def validate(_object, context, value)
      target = Target.find_by(id: value[:target_id])
      course = target.course
      student =
        context[:current_user]
          .founders
          .joins(:level)
          .where(levels: { course_id: course })
          .first
      target_status = Targets::StatusService.new(target, student).status
      submittable = target.evaluation_criteria.exists?
      submission_required =
        target_status.in?(
          [
            Targets::StatusService::STATUS_PENDING,
            Targets::StatusService::STATUS_FAILED
          ]
        )
      submitted_but_resubmittable =
        target.resubmittable? &&
          target_status == Targets::StatusService::STATUS_PASSED

      if submittable && (submission_required || submitted_but_resubmittable)
        return
      end

      I18n.t(
        'mutations.create_submission.blocked_submission_status_error',
        target_status: target_status
      )
    end
  end

  class AttemptedMinimumQuestions < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      target = Target.find_by(id: value[:target_id])
      checklist = value[:checklist]
      target
        .checklist
        .each_with_object([]) do |c, result|
          next if c['optional'] == true

          item = checklist.select { |i| i['title'] == c['title'] }

          if item.present? && item.count == 1 && item.first['result'].present?
            next
          end

          result <<
            I18n.t(
              'mutations.create_submission.missing_answer_error',
              title: c['title']
            )
        end
    end
  end

  class ValidResponse < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      checklist = value[:checklist]

      if checklist.respond_to?(:all?) && checklist.all? do |item|
           item['title'].is_a?(String) &&
             item['kind'].in?(Target.valid_checklist_kind_types) &&
             item['status'] == TimelineEvent::CHECKLIST_STATUS_NO_ANSWER &&
             item['result'].present? &&
             valid_result(item['kind'], item['result'], value[:file_ids])
         end
        return
      end

      I18n.t('mutations.create_submission.invalid_submission_checklist')
    end

    def valid_result(kind, result, file_ids)
      case kind
      when Target::CHECKLIST_KIND_FILES
        (result - file_ids).empty?
      when Target::CHECKLIST_KIND_AUDIO
        (result.split - file_ids).empty?
      when Target::CHECKLIST_KIND_LINK
        result.length >= 3 && result.length <= 2048
      when Target::CHECKLIST_KIND_LONG_TEXT
        result.length >= 1 && result.length <= 10_000
      when Target::CHECKLIST_KIND_MULTI_CHOICE,
           Target::CHECKLIST_KIND_SHORT_TEXT
        result.length >= 1 && result.length <= 500
      else
        false
      end
    end
  end

  class ValidFileIdsInChecklist < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      file_ids = value[:file_ids]

      file_items =
        value[:checklist].filter do |item|
          (item['kind'] == 'files' || item['kind'] == 'audio')
        end

      return if file_ids.blank?

      if file_items.map { |item| item['result'] }.flatten.sort == file_ids.sort
        return
      end

      I18n.t('mutations.create_submission.invalid_files_attached')
    end
  end

  included do
    argument :target_id, GraphQL::Types::ID, required: true
    argument :checklist, GraphQL::Types::JSON, required: true
    argument :file_ids, [GraphQL::Types::ID], required: true

    validates ValidResponse => {}
    validates ValidFileIdsInChecklist => {}
    validates AttemptedMinimumQuestions => {}
    validates AllFilesAreNew => {}
    validates MaximumThreeAttachmentsPerItem => {}
    validates EnsureSubmittability => {}
  end
end
