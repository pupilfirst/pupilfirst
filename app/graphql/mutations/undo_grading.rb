module Mutations
  class UndoGrading < ApplicationQuery
    class MustBeGraded < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        submission = TimelineEvent.find_by(id: value[:submission_id])

        unless submission&.evaluated_at?
          return I18n.t("mutations.undo_grading.must_be_graded")
        end
      end
    end

    include QueryAuthorizeReviewSubmissions
    include ValidateSubmissionGradable

    validates MustBeGraded => {}

    description "Delete grading for the submission."

    field :success, Boolean, null: false

    def resolve(_params)
      notify(
        :success,
        I18n.t("mutations.undo_grading.success_notification.title"),
        I18n.t("mutations.undo_grading.success_notification.description")
      )

      { success: undo_grading }
    end

    def undo_grading
      TimelineEvent.transaction do
        # Clear existing grades
        TimelineEventGrade.where(timeline_event: submission).destroy_all

        if submission.target.assignments.not_archived.first.milestone
          submission.students.find_each do |student|
            student.update!(completed_at: nil)
          end
        end

        # Clear evaluation info
        submission.update!(
          passed_at: nil,
          evaluator_id: nil,
          evaluated_at: nil,
          checklist: checklist
        )
      end
    end

    def checklist
      submission.checklist.map do |c|
        c["status"] = TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
        c
      end
    end

    def submission
      @submission = TimelineEvent.find_by(id: @params[:submission_id])
    end

    def course
      @course ||= submission&.course
    end
  end
end
