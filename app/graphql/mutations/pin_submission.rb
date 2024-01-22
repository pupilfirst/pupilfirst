module Mutations
  class PinSubmission < ApplicationQuery
    argument :pinned, Boolean, required: true
    argument :submission_id, String, required: true

    description "Pin or unpin a submission"

    field :success, Boolean, null: false

    def resolve(_params)
      submission.pinned = @params[:pinned]
      submission.save!
      { success: true }
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
