module Mutations
  class ArchiveSubmissionComment < ApplicationQuery
    argument :submission_comment_id, String, required: true

    description "Archive a submission comment"

    field :success, Boolean, null: false

    def resolve(_params)
      submission_comment.archived_at = Time.zone.now
      submission_comment.archived_by = current_user

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
