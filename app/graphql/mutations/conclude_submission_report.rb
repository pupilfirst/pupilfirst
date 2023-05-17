module Mutations
  class ConcludeSubmissionReport < ApplicationQuery
    include QueryAuthorizeCoach
    include ValidateSubmissionGradable

    class ValidConclusionStatuses < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        if status.in?(%w[queued in_progress])
          return I18n.t('mutations.conclude_submission_report.invalid_status')
        end
      end
    end

    validates ValidConclusionStatuses => {}

    argument :test_report,
             String,
             required: false,
             validates: {
               length: {
                 maximum: 10_000
               }
             }
    argument :status, Types::SubmissionReportStatusType, required: true
    argument :context_name, String, required: true
    argument :context_title, String, required: false
    argument :target_url, String, required: false

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
          SubmissionReport.find_by(submission_id: @params[:submission_id], context_name: @params[:context_name])
        if report.present?
          report.update!(
            test_report: @params[:test_report],
            status: @params[:status],
            started_at: report.started_at || time_now,
            completed_at: time_now,
            context_title: @params[:context_title],
            target_url: @params[:target_url]
          )
        else
          SubmissionReport.create!(
            submission_id: @params[:submission_id],
            test_report: @params[:test_report],
            status: @params[:status],
            started_at: time_now,
            completed_at: time_now,
            context_name: @params[:context_name],
            context_title: @params[:context_title],
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
