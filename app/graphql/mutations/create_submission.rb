module Mutations
  class CreateSubmission < ApplicationQuery
    include QueryAuthorizeStudent
    include LevelUpEligibilityComputable
    include ValidateStudentSubmission

    description 'Create a new submission for a target'

    field :submission, Types::SubmissionType, null: true
    field :level_up_eligibility, Types::LevelUpEligibility, null: true

    def resolve(_params)
      submission = create_submission
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.create_submission.success_notification')
      )
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
