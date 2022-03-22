module Mutations
  class CreateCompletedSubmissionReport < ApplicationQuery
    include QueryAuthorizeCoach
    include ValidateSubmissionGradable

    argument :submission_id, ID, required: true
    argument :description, String, required: true
    argument :conclusion, Types::SubmissionReportConclusionType, required: true

    description 'Create completed report for a submissions'

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
            status: 'completed',
            description: @params[:description],
            conclusion: @params[:conclusion],
            started_at: report.started_at || Time.zone.now,
            completed_at: Time.zone.now
          )
        else
          SubmissionReport.create!(
            status: 'completed',
            description: @params[:description],
            conclusion: @params[:conclusion],
            started_at: Time.zone.now,
            completed_at: Time.zone.now
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
