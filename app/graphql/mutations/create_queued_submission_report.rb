module Mutations
  class CreateQueuedSubmissionReport < ApplicationQuery
    include QueryAuthorizeCoach
    include ValidateSubmissionGradable

    argument :submission_id, ID, required: true
    argument :description, String, required: true

    description 'Create queued report for a submissions'

    field :success, Boolean, null: false

    def resolve(_params)
      save_report
      { success: true }
    end

    private

    def save_report
      SubmissionReport.transaction do
        SubmissionReport
          .where(submission_id: @params[:submission_id])
          .first_or_create!(
            status: 'queued',
            description: @params[:description],
            started_at: nil,
            completed_at: nil,
            conclusion: nil
          )
      end
    end

    def allow_token_auth?
      true
    end

    def course
      @course ||= submission&.course
    end

    def submission
      @submission = TimelineEvent.find_by(id: @params[:submission_id])
    end
  end
end
