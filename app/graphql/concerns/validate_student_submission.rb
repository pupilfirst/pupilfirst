module ValidateStudentSubmission
  extend ActiveSupport::Concern

  class EnsureSubmittability < GraphQL::Schema::Validator
    def validate(_object, context, value)
      target = Target.find_by(id: value[:target_id])
      assignment = target.assignments.not_archived.first
      course = target.course
      student =
        context[:current_user]
          .students
          .joins(:cohort)
          .where(cohorts: { course_id: course })
          .first
      target_status = Targets::StatusService.new(target, student).status
      submittable =
        assignment.checklist.present? || assignment.evaluation_criteria.present?
      submission_required =
        target_status.in?(
          [
            Targets::StatusService::STATUS_PENDING,
            Targets::StatusService::STATUS_FAILED
          ]
        )
      submitted_but_resubmittable =
        assignment.checklist.present? &&
          target_status == Targets::StatusService::STATUS_PASSED

      if submittable && (submission_required || submitted_but_resubmittable)
        return
      end

      I18n.t(
        "mutations.create_submission.blocked_submission_status_error",
        target_status: target_status
      )
    end
  end

  class AttemptedMinimumQuestions < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      assignment =
        Target.find_by(id: value[:target_id]).assignments.not_archived.last
      checklist = value[:checklist]
      assignment
        .checklist
        .each_with_object([]) do |c, result|
          next if c["optional"] == true

          item = checklist.select { |i| i["title"] == c["title"] }

          if item.present? && item.count == 1 && item.first["result"].present?
            next
          end

          result << I18n.t(
            "mutations.create_submission.missing_answer_error",
            title: c["title"]
          )
        end
    end
  end

  class ValidResponse < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      checklist = value[:checklist]

      if checklist.respond_to?(:all?) &&
           checklist.all? { |item|
             item["title"].is_a?(String) &&
               item["kind"].in?(Assignment.valid_checklist_kind_types) &&
               item["status"] == TimelineEvent::CHECKLIST_STATUS_NO_ANSWER &&
               item["result"].present? &&
               valid_result(item["kind"], item["result"], value[:file_ids])
           }
        return
      end

      I18n.t("mutations.create_submission.invalid_submission_checklist")
    end

    def valid_result(kind, result, file_ids)
      case kind
      when Assignment::CHECKLIST_KIND_FILES
        (result - file_ids).empty?
      when Assignment::CHECKLIST_KIND_AUDIO
        (result.split - file_ids).empty?
      when Assignment::CHECKLIST_KIND_LINK
        result.length >= 3 && result.length <= 2048
      when Assignment::CHECKLIST_KIND_LONG_TEXT
        result.length >= 1 && result.length <= 10_000
      when Assignment::CHECKLIST_KIND_MULTI_CHOICE,
           Assignment::CHECKLIST_KIND_SHORT_TEXT
        result.length >= 1 && result.length <= 500
      else
        false
      end
    end
  end

  class ValidateFileAttachments < GraphQL::Schema::Validator
    include ValidatorCombinable

    def validate(_object, _context, value)
      @file_ids = value[:file_ids]

      @files = TimelineEventFile.where(id: value[:file_ids])

      @file_items =
        value[:checklist].filter do |item|
          (item["kind"] == "files" || item["kind"] == "audio")
        end

      combine(
        maximum_three_attachments_per_item,
        valid_file_ids_in_checklist,
        all_files_are_new
      )
    end

    def maximum_three_attachments_per_item
      return if @file_ids.blank?

      if @file_items
           .select { |item| item["result"].split.flatten.length > 3 }
           .empty?
        return
      end

      I18n.t("mutations.create_submission.item_file_limit_error")
    end

    def valid_file_ids_in_checklist
      return if @file_ids.blank?

      return if @file_items.pluck("result").flatten.sort == @file_ids.sort

      I18n.t("mutations.create_submission.invalid_files_attached")
    end

    def all_files_are_new
      return if @file_ids.blank?

      return if @files.where.not(timeline_event_id: nil).blank?

      I18n.t("mutations.create_submission.linked_file_exists_error")
    end
  end

  included do
    argument :target_id, GraphQL::Types::ID, required: true
    argument :checklist, GraphQL::Types::JSON, required: true
    argument :file_ids, [GraphQL::Types::ID], required: true
    argument :anonymous, GraphQL::Types::Boolean, required: true

    validates ValidResponse => {}
    validates ValidateFileAttachments => {}
    validates AttemptedMinimumQuestions => {}
    validates EnsureSubmittability => {}
  end
end
