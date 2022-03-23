module Mutations
  class ConcludeSubmissionReport < ApplicationQuery
    include QueryAuthorizeCoach
    include ValidateSubmissionGradable

    argument :submission_id, ID, required: true
    argument :description,
             String,
             required: true,
             validates: {
               length: {
                 maximum: 1000
               }
             }
    argument :conclusion, Types::SubmissionReportConclusionType, required: true

    description 'Create completed report for a submission'

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
            started_at: report.started_at || time_now,
            completed_at: time_now
          )
        else
          SubmissionReport.create!(
            status: 'completed',
            description: @params[:description],
            conclusion: @params[:conclusion],
            started_at: time_now,
            completed_at: time_now
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

    def time_now
      @time_now ||= Time.zone.now
    end
  end
end
