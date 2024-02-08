module Mutations
  class ArchiveSubmissionComment < ApplicationQuery
    argument :submission_comment_id, String, required: true

    description "Archive a submission comment"

    field :success, Boolean, null: false

    def resolve(_params)
      submission_comment.update!(archived_at: Time.zone.now)
      { success: true }
    end

    def query_authorized?
      current_user.id == submission_comment.user_id
    end

    def submission_comment
      @submission_comment ||=
        SubmissionComment.find_by(id: @params[:submission_comment_id])
    end
  end
end
