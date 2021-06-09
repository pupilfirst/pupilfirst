module Mutations
  class CreateSubmission < ApplicationQuery
    include QueryAuthorizeStudent
    include LevelUpEligibilityComputable

    argument :target_id, ID, required: true
    argument :checklist, GraphQL::Types::JSON, required: true
    argument :file_ids, [ID], required: true

    description 'Create a new submission for a target'

    field :submission, Types::SubmissionType, null: true
    field :level_up_eligibility, Types::LevelUpEligibility, null: true

    class AllFilesAreNew < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        files = TimelineEventFile.where(id: value[:file_ids])

        return if files.where.not(timeline_event_id: nil).blank?

        'Some file attachments have already been linked to a submission'
      end
    end

    validates AllFilesAreNew => {}

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

        'No more than three files can be attached to a submission item'
      end
    end

    validates MaximumThreeAttachmentsPerItem => {}

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

        "The status of this target is '#{target_status}', so you cannot add a new submission; please reload the page"
      end
    end

    validates EnsureSubmittability => {}

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

            result << "Missing answer for question: #{c['title']}"
          end
      end
    end

    validates AttemptedMinimumQuestions => {}

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

        'Submission checklist is not valid.'
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

    validates ValidResponse => {}

    class ValidFileIdsInChecklist < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        file_ids = value[:file_ids]

        file_items =
          value[:checklist].filter do |item|
            (item['kind'] == 'files' || item['kind'] == 'audio')
          end

        return if file_ids.blank?

        if file_items.map { |item| item['result'] }.flatten.sort ==
             file_ids.sort
          return
        end

        'some files attached are invalid'
      end
    end

    validates ValidFileIdsInChecklist => {}

    def resolve(_params)
      submission = create_submission

      notify(:success, 'Done!', 'Your submission has been queued for review.')
      { submission: submission, level_up_eligibility: level_up_eligibility }
    end

    def create_submission
      TimelineEvent.transaction do
        params = { target: target, checklist: @params[:checklist] }

        timeline_event =
          TimelineEvents::CreateService.new(params, student).execute

        timeline_event_files.each do |timeline_event_file|
          if @params[:file_ids].any?
            timeline_event_file.update!(timeline_event: timeline_event)
          end
        end

        timeline_event
      end
    end

    def timeline_event_files
      @timeline_event_files ||= TimelineEventFile.where(id: @params[:file_ids])
    end
  end
end
