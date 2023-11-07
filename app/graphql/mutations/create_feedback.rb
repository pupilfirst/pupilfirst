module Mutations
  class CreateFeedback < ApplicationQuery
    include QueryAuthorizeReviewSubmissions
    include ValidateSubmissionGradable

    argument :feedback, String, required: true

    description "Create feedback for submission"

    field :success, Boolean, null: false

    def resolve(_params)
      notify(
        :success,
        I18n.t("mutations.create_feedback.success_notification.title"),
        I18n.t("mutations.create_feedback.success_notification.description")
      )

      { success: create_feedback }
    end

    def create_feedback
      StartupFeedback.transaction do
        startup_feedback =
          StartupFeedback.create!(
            feedback: @params[:feedback],
            faculty: coach,
            timeline_event: submission
          )
        StartupFeedbackModule::EmailService.new(startup_feedback).send
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

    def allow_token_auth?
      true
    end
  end
end
