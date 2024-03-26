module Mutations
  class CreateSubmission < ApplicationQuery
    include QueryAuthorizeStudent
    include ValidateStudentSubmission

    description "Create a new submission for a target"

    field :submission, Types::SubmissionType, null: true

    def resolve(_params)
      submission = create_submission

      success_message =
        (
          if submission.passed_at.blank?
            I18n.t("mutations.create_submission.success_notification")
          else
            I18n.t("mutations.create_submission.form_success_notification")
          end
        )

      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        success_message
      )

      { submission: submission }
    end

    def create_submission
      TimelineEvent.transaction do
        params = {
          target: target,
          checklist: @params[:checklist],
          anonymous: @params[:anonymous]
        }

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
