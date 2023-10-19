module Mutations
  class UnassignReviewer < ApplicationQuery
    include QueryAuthorizeReviewSubmissions
    include ValidateSubmissionGradable

    description "Unassign reviewer for a submission"

    field :success, Boolean, null: false

    def resolve(_params)
      unassign_reviewer
      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        I18n.t("mutations.unassign_reviewer.success_notification")
      )
      { success: true }
    end

    class ValidateSubmission < GraphQL::Schema::Validator
      include ValidatorCombinable
      def validate(_object, context, value)
        @submission = TimelineEvent.find_by(id: value[:submission_id])
        @coach = context[:current_user].faculty

        combine(
          submission_not_graded,
          submission_should_be_assigned,
          submission_not_assigned_to_another_coach
        )
      end

      def submission_not_graded
        return unless @submission.reviewed?

        I18n.t("mutations.assign_reviewer.submission_graded_error")
      end

      def submission_should_be_assigned
        return if @submission.reviewer_id.present?

        I18n.t("mutations.unassign_reviewer.submission_not_assigned")
      end

      def submission_not_assigned_to_another_coach
        return if @submission.reviewer_id.blank?

        return if @submission.reviewer == @coach

        I18n.t(
          "mutations.unassign_reviewer.submission_assigned_to_another_coach"
        )
      end
    end

    validates ValidateSubmission => {}

    private

    def unassign_reviewer
      TimelineEvent.transaction do
        submission.update!(reviewer: nil, reviewer_assigned_at: nil)
      end
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
  end
end
