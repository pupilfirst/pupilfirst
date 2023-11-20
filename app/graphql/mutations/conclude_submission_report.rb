module Mutations
  class ConcludeSubmissionReport < ApplicationQuery
    include QueryAuthorizeReviewSubmissions
    include ValidateSubmissionGradable

    class ValidConclusionStatuses < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        if value[:status].in?(%w[queued in_progress])
          return I18n.t("mutations.conclude_submission_report.invalid_status")
        end
      end
    end

    validates ValidConclusionStatuses => {}

    argument :report,
             String,
             required: false,
             validates: {
               length: {
                 maximum: 10_000
               }
             }
    argument :status, Types::SubmissionReportStatusType, required: true
    argument :reporter, String, required: true
    argument :heading, String, required: false
    argument :target_url, String, required: false

    description "Create completed report for a submission"

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
            status: @params[:status],
            started_at: report.started_at || time_now,
            completed_at: time_now,
            heading: @params[:heading],
            target_url: @params[:target_url].presence || report.target_url
          )
        else
          SubmissionReport.create!(
            submission_id: @params[:submission_id],
            report: @params[:report],
            status: @params[:status],
            started_at: time_now,
            completed_at: time_now,
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

    def time_now
      @time_now ||= Time.zone.now
    end
  end
end
