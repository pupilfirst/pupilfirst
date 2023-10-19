module Mutations
  class ReassignReviewer < ApplicationQuery
    include QueryAuthorizeReviewSubmissions
    include ValidateSubmissionGradable

    description "Reassign reviewer for a submission"

    field :reviewer, Types::UserProxyType, null: false

    def resolve(_params)
      reassign_reviewer
      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        I18n.t("mutations.reassign_reviewer.success_notification")
      )
      { reviewer: coach }
    end

    class ValidateSubmission < GraphQL::Schema::Validator
      include ValidatorCombinable
      def validate(_object, context, value)
        @submission = TimelineEvent.find_by(id: value[:submission_id])
        @coach = context[:current_user].faculty

        combine(submission_not_graded, submission_not_assigned_to_coach)
      end

      def submission_not_graded
        return unless @submission.reviewed?

        I18n.t("mutations.reassign_reviewer.submission_graded_error")
      end

      def submission_not_assigned_to_coach
        return if @submission.reviewer_id.nil?

        return unless @submission.reviewer == @coach

        I18n.t("mutations.reassign_reviewer.submission_not_assigned_to_coach")
      end
    end

    validates ValidateSubmission => {}

    private

    def reassign_reviewer
      TimelineEvent.transaction do
        submission.update!(reviewer: coach, reviewer_assigned_at: Time.zone.now)
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
