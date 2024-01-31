module Mutations
  class HideSubmissionComment < ApplicationQuery
    argument :submission_comment_id, String, required: true
    argument :hide, Boolean, required: true

    description "Hide or unhide a submission comment from discussion"

    field :comment, Types::SubmissionCommentType, null: false

    def resolve(_params)
      if @params[:hide]
        submission_comment.hidden_at = Time.zone.now
        submission_comment.hidden_by = current_user
      else
        submission_comment.hidden_at = nil
        submission_comment.hidden_by = nil
      end

      submission_comment.save!
      {
        comment: {
          id: submission_comment.id,
          user_id: submission_comment.user_id,
          submission_id: submission_comment.timeline_event_id,
          comment: submission_comment.comment,
          user_name: current_user.name,
          updated_at: submission_comment.updated_at,
          reactions: [],
          moderation_reports: [],
          hidden_at: submission_comment.hidden_at,
          hidden_by_id: submission_comment.hidden_by_id
        }
      }
    end

    #TODO implement authorization
    def query_authorized?
      return true
    end

    def submission
      @submission ||= submission_comment.timeline_event
    end

    def submission_comment
      @submission_comment ||=
        SubmissionComment.find_by(id: @params[:submission_comment_id])
    end

    def course
      @course ||= submission&.course
    end
  end
end
