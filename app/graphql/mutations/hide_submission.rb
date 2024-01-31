module Mutations
  class HideSubmission < ApplicationQuery
    argument :submission_id, String, required: true

    description "Hide a submission from discussion"

    field :success, Boolean, null: false

    def resolve(_params)
      submission.hidden_at = Time.zone.now
      submission.hidden_by = current_user

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
