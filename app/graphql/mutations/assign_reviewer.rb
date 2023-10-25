module Mutations
  class AssignReviewer < ApplicationQuery
    include QueryAuthorizeReviewSubmissions
    include ValidateSubmissionGradable

    description "Assign reviewer for a submission"

    field :reviewer, Types::UserProxyType, null: false

    def resolve(_params)
      assign_reviewer
      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        I18n.t("mutations.assign_reviewer.success_notification")
      )
      { reviewer: coach }
    end

    class ValidateSubmission < GraphQL::Schema::Validator
      include ValidatorCombinable
      def validate(_object, _context, value)
        @submission = TimelineEvent.find_by(id: value[:submission_id])

        combine(submission_not_graded, submission_should_be_unassigned)
      end

      def submission_not_graded
        return unless @submission.reviewed?

        I18n.t("mutations.assign_reviewer.submission_graded_error")
      end

      def submission_should_be_unassigned
        return if @submission.reviewer_id.blank?

        I18n.t("mutations.assign_reviewer.submission_already_assigned")
      end
    end

    validates ValidateSubmission => {}

    private

    def assign_reviewer
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
