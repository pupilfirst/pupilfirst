module Mutations
  class HideSubmissionComment < ApplicationQuery
    argument :submission_comment_id, String, required: true

    description "Hide a submission comment from discussion"

    field :success, Boolean, null: false

    def resolve(_params)
      submission_comment.hidden_at = Time.zone.now
      submission_comment.hidden_by = current_user

      submission_comment.save!
      { success: true }
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
