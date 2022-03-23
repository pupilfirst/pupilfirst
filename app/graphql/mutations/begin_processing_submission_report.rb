module Mutations
  class BeginProcessingSubmissionReport < ApplicationQuery
    include QueryAuthorizeCoach
    include ValidateSubmissionGradable

    argument :submission_id, ID, required: true
    argument :description,
             String,
             required: false,
             validates: {
               length: {
                 maximum: 1000
               }
             }

    description 'Create in progress report for a submission'

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
            status: 'in_progress',
            description: @params[:description],
            started_at: Time.zone.now,
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
