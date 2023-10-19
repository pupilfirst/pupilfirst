module Mutations
  class CreateGrading < ApplicationQuery
    include QueryAuthorizeReviewSubmissions
    include DevelopersNotifications
    include ValidateSubmissionGradable

    argument :grades, [Types::GradeInputType], required: true
    argument :feedback,
             String,
             required: false,
             validates: {
               length: {
                 maximum: 10_000
               }
             }
    argument :checklist, GraphQL::Types::JSON, required: true
    argument :note,
             String,
             required: false,
             validates: {
               length: {
                 maximum: 10_000
               }
             }

    description "Create grading for submission"

    field :success, Boolean, null: false

    def resolve(_params)
      grade
      notify(
        :success,
        I18n.t("mutations.create_grading.grade_recorded"),
        I18n.t("mutations.create_grading.success_notification")
      )
      { success: true }
    end

    class ValidateReviewData < GraphQL::Schema::Validator
      include ValidatorCombinable
      def validate(_object, _context, value)
        @submission_id = value[:submission_id]
        @submission = TimelineEvent.find_by(id: value[:submission_id])
        @checklist = value[:checklist]
        @evaluation_criteria = @submission.evaluation_criteria
        @grades = value[:grades]
        combine(
          submission_exists,
          submission_not_graded,
          valid_evaluation_criteria,
          right_shape_for_checklist,
          checklist_data_is_not_mutated,
          valid_grading
        )
      end

      def submission_exists
        return if @submission.present?

        I18n.t(
          "mutations.create_grading.submission_missing_error",
          submission_id: @submission_id
        )
      end

      def submission_not_graded
        return unless @submission.reviewed?

        I18n.t("mutations.create_grading.submission_graded_error")
      end

      def valid_evaluation_criteria
        return if @evaluation_criteria.present?

        I18n.t(
          "mutations.create_grading.evaluation_criteria_error",
          submission_id: @submission_id
        )
      end

      def right_shape_for_checklist
        if @checklist.respond_to?(:all?) &&
             @checklist.all? { |item|
               item["title"].is_a?(String) &&
                 item["kind"].in?(Target.valid_checklist_kind_types) &&
                 item["status"].in?(
                   [
                     TimelineEvent::CHECKLIST_STATUS_FAILED,
                     TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
                   ]
                 ) &&
                 (item["result"].is_a?(String) || item["result"].is_a?(Array))
             }
          return
        end

        I18n.t("mutations.create_grading.invalid_checklist_shape_error")
      end

      def checklist_data_is_not_mutated
        old_checklist =
          @submission.checklist.map do |c|
            [
              c["title"],
              c["kind"],
              c["kind"] == "files" ? c["result"].sort : c["result"]
            ]
          end

        new_checklist =
          @checklist.map do |c|
            [
              c["title"],
              c["kind"],
              c["kind"] == "files" ? c["result"].sort : c["result"]
            ]
          end

        if (old_checklist - new_checklist).empty? &&
             old_checklist.count == new_checklist.count
          return
        end

        if (old_checklist - new_checklist).empty? &&
             old_checklist.count == new_checklist.count
          return
        end

        I18n.t("mutations.create_grading.invalid_checklist_values_error")
      end

      def valid_grading
        return unless valid_grading?

        I18n.t(
          "mutations.create_grading.invalid_grading_error",
          grades_data: @grades.to_json
        )
      end

      private

      def grade_hash
        @grade_hash ||=
          @grades.each_with_object({}) do |incoming_grade, grade_hash|
            criteria_id = incoming_grade[:evaluation_criterion_id]
            grade = incoming_grade[:grade]
            grade_hash[criteria_id] = grade
          end
      end

      def valid_grading?
        all_criteria_graded? && all_grades_valid?
      end

      def all_criteria_graded?
        (@evaluation_criteria.pluck(:id) - grade_hash.keys).empty?
      end

      def all_grades_valid?
        grade_hash.all? { |ec_id, grade| grade.in?(1..max_grades[ec_id]) }
      end

      def max_grades
        @max_grades ||=
          grade_hash.keys.index_with do |ec_id|
            @evaluation_criteria.find(ec_id).max_grade
          end
      end
    end

    private

    def grade
      TimelineEvent.transaction do
        evaluation_criteria.each do |criterion|
          TimelineEventGrade.create!(
            timeline_event: submission,
            evaluation_criterion: criterion,
            grade: grade_hash[criterion.id.to_s]
          )
        end

        submission.update!(
          passed_at: (failed? ? nil : Time.zone.now),
          evaluator: coach,
          evaluated_at: Time.zone.now,
          checklist: @params[:checklist],
          reviewer: nil,
          reviewer_assigned_at: nil
        )

        TimelineEvents::AfterGradingJob.perform_later(submission)
        update_coach_note if @params[:note].present?
        send_feedback if @params[:feedback].present?
      end

      publish(course, :submission_graded, current_user, submission)
    end

    def submission
      @submission = TimelineEvent.find_by(id: @params[:submission_id])
    end

    def course
      @course ||= submission&.course
    end

    def coach
      @coach ||= current_user.faculty
    end

    def evaluation_criteria
      @evaluation_criteria ||= submission.evaluation_criteria
    end

    def grade_hash
      @grade_hash ||=
        @params[:grades].each_with_object({}) do |incoming_grade, grade_hash|
          criteria_id = incoming_grade[:evaluation_criterion_id]
          grade = incoming_grade[:grade]
          grade_hash[criteria_id] = grade
        end
    end

    def pass_grades
      @pass_grades ||=
        grade_hash.keys.index_with do |ec_id|
          evaluation_criteria.find(ec_id).pass_grade
        end
    end

    def failed?
      grade_hash.any? { |ec_id, grade| grade < pass_grades[ec_id] }
    end

    def allow_token_auth?
      true
    end

    def update_coach_note
      submission.students.each do |student|
        CoachNote.create!(
          note: @params[:note],
          author_id: current_user.id,
          student_id: student.id
        )
      end
    end

    def send_feedback
      startup_feedback =
        StartupFeedback.create!(
          feedback: @params[:feedback],
          faculty: coach,
          timeline_event: submission
        )

      StartupFeedbackModule::EmailService.new(
        startup_feedback,
        include_grades: true
      ).send
    end
  end
end
