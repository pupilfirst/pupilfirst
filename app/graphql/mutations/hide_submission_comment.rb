module Mutations
  class HideSubmissionComment < ApplicationQuery
    argument :submission_comment_id, String, required: true
    argument :hide, Boolean, required: true

    description "Hide or unhide a submission comment from discussion"

    field :success, Boolean, null: false

    def resolve(_params)
      if @params[:hide]
        submission_comment.hidden_at = Time.zone.now
        submission_comment.hidden_by = current_user
      else
        submission_comment.hidden_at = nil
        submission_comment.hidden_by = nil
      end

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
