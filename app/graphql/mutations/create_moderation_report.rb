module Mutations
  class CreateModerationReport < ApplicationQuery
    argument :reason, String, required: true
    argument :reportable_id, String, required: true
    argument :reportable_type, String, required: true

    description "Create a moderation report on either a submission or comment"

    field :moderation_report, Types::ModerationReportType, null: false

    def resolve(_params)
      moderation_report =
        ModerationReport.create(
          reason: @params[:reason],
          reportable_id: @params[:reportable_id],
          reportable_type: @params[:reportable_type],
          user_id: current_user.id
        )
      {
        moderation_report: {
          id: moderation_report.id,
          reportable_id: moderation_report.reportable_id,
          reportable_type: moderation_report.reportable_type,
          reason: moderation_report.reason,
          user_id: current_user.id
        }
      }
    end

    #TODO implement authorization
    def query_authorized?
      return true
    end

    def submission
      if @params[:reportable_type] == "TimelineEvent"
        @submission ||= TimelineEvent.find_by(id: @params[:reportable_id])
      else
        @submission ||=
          SubmissionComment.find_by(id: @params[:reportable_id]).timeline_event
      end
    end

    def course
      @course ||= submission&.course
    end
  end
end
