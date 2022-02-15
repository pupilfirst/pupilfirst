module Mutations
  class CreateSubmissionReports < ApplicationQuery
    include QueryAuthorizeCoach
    include ValidateSubmissionGradable

    argument :submission_id, ID, required: true
    argument :description, String, required: true
    argument :status, Types::SubmissionReportStatusType, required: true

    description 'Create reports for submissions'

    field :success, Boolean, null: false

    def resolve(_params)
      save_report
      { success: true }
    end

    private

    def save_report
      SubmissionReport.transaction do
        report =
          SubmissionReport.find_by(submission_id: @params[:submission_id])
        if report.present?
          report.update!(
            description: @params[:description],
            status: @params[:status]
          )
        else
          SubmissionReport.create!(
            submission_id: @params[:submission_id],
            description: @params[:description],
            status: @params[:status]
          )
        end
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
