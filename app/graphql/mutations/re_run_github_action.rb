module Mutations
  class ReRunGithubAction < ApplicationQuery
    include QueryAuthorizeReviewSubmissions
    argument :submission_id, ID, required: false

    description "Re-run the Github Action for a submission"

    field :success, Boolean, null: false

    def resolve(_params)
      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        I18n.t("mutations.re_run_github_action.success_notification")
      )
      Github::RunActionsJob.perform_later(submission, re_run: true)
      { success: true }
    end

    class StudentHasAGithubAccount < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        submission = TimelineEvent.find_by(id: value[:submission_id])

        if submission.students.first.github_repository.blank?
          return(
            I18n.t(
              "mutations.re_run_github_action.validation_error.student_has_no_github_account"
            )
          )
        end
      end
    end

    class TargetHasAnActionConfigured < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        submission = TimelineEvent.find_by(id: value[:submission_id])

        if submission.target.action_config.blank?
          return(
            I18n.t(
              "mutations.re_run_github_action.validation_error.target_does_not_have_github_action"
            )
          )
        end
      end
    end

    validates TargetHasAnActionConfigured => {}

    private

    def submission
      @submission ||= TimelineEvent.find_by(id: @params[:submission_id])
    end

    def course
      @course ||= submission&.target&.course
    end
  end
end
