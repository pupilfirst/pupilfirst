module Mutations
  class BeginProcessingSubmissionReport < ApplicationQuery
    include QueryAuthorizeReviewSubmissions
    include ValidateSubmissionGradable

    argument :report,
             String,
             required: false,
             validates: {
               length: {
                 maximum: 1000
               }
             }
    argument :reporter, String, required: true
    argument :heading, String, required: false
    argument :target_url, String, required: false

    description "Create in progress report for a submission"

    field :success, Boolean, null: false

    def resolve(_params)
      save_report
      { success: true }
    end

    private

    def save_report
      SubmissionReport.transaction do
        report =
          SubmissionReport.find_by(
            submission_id: @params[:submission_id],
            reporter: @params[:reporter]
          )

        if report.present?
          report.update!(
            report: @params[:report],
            status: "in_progress",
            started_at: Time.zone.now,
            completed_at: nil,
            heading: @params[:heading],
            target_url: @params[:target_url].presence || report.target_url
          )
        else
          SubmissionReport.create!(
            submission_id: @params[:submission_id],
            report: @params[:report],
            status: "in_progress",
            started_at: Time.zone.now,
            completed_at: nil,
            reporter: @params[:reporter],
            heading: @params[:heading],
            target_url: @params[:target_url]
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
