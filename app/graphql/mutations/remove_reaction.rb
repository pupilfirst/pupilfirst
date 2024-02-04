module Mutations
  class RemoveReaction < ApplicationQuery
    argument :reaction_id, String, required: true

    description "Remove a reaction from either a submission or comment"

    field :success, Boolean, null: false

    def resolve(_params)
      Reaction.find_by(id: @params[:reaction_id]).delete
      { success: true }
    end

    #TODO implement authorization
    def query_authorized?
      return true
    end

    def submission
      if @params[:reactionable_type] == "TimelineEvent"
        @submission ||= TimelineEvent.find_by(id: @params[:reactionable_id])
      else
        @submission ||= submission_comment.timeline_event
      end
    end

    def submission_comment
      @submission_comment ||=
        SubmissionComment.find_by(id: @params[:reactionable_id])
    end

    def course
      @course ||= submission&.course
    end
  end
end
