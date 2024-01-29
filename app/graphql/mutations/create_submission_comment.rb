module Mutations
  class CreateSubmissionComment < ApplicationQuery
    argument :comment, String, required: true
    argument :submission_id, String, required: true

    description "Create a submission comment"

    field :comment, Types::SubmissionCommentType, null: false

    def resolve(_params)
      comment =
        submission.submission_comments.create(
          comment: @params[:comment],
          user_id: current_user.id
        )
      {
        comment: {
          id: comment.id,
          user_id: comment.user_id,
          submission_id: comment.timeline_event_id,
          comment: comment.comment,
          user_name: current_user.name,
          updated_at: comment.updated_at,
          reactions: [],
          moderation_reports: []
        }
      }
    end

    #TODO implement authorization
    def query_authorized?
      return true
    end

    def submission
      @submission ||= TimelineEvent.find_by(id: @params[:submission_id])
    end

    def course
      @course ||= submission&.course
    end
  end
end
