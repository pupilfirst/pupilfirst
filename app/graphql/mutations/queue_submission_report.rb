module Mutations
  class QueueSubmissionReport < ApplicationQuery
    include QueryAuthorizeCoach
    include ValidateSubmissionGradable

    argument :test_report,
             String,
             required: false,
             validates: {
               length: {
                 maximum: 1000
               }
             }
    argument :context_name, String, required: true
    argument :context_title, String, required: false
    argument :target_url, String, required: false

    description 'Create queued report for a submission'

    field :success, Boolean, null: false

    def resolve(_params)
      save_report
      { success: true }
    end

    private

    def save_report
      SubmissionReport.transaction do
        report = SubmissionReport.find_by(submission_id: @params[:submission_id], context_name: @params[:context_name])
        if report.present?
          report.update!(
            test_report: @params[:test_report],
            status: 'queued',
            started_at: nil,
            completed_at: nil,
            context_title: @params[:context_title],
            target_url: @params[:target_url]
          )
        else
          SubmissionReport.create!(
            submission_id: @params[:submission_id],
            test_report: @params[:test_report],
            status: 'queued',
            started_at: nil,
            completed_at: nil,
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
  end
end
