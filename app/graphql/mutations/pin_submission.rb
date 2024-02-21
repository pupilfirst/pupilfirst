module Mutations
  class PinSubmission < ApplicationQuery
    argument :pin, Boolean, required: true
    argument :submission_id, String, required: true

    description "Pin or unpin a submission"

    field :success, Boolean, null: false

    def resolve(_params)
      submission.pinned = @params[:pin]
      submission.save!
      { success: true }
    end

    def query_authorized?
      return false if current_user.blank?

      # school admin or course author
      return true if current_school_admin.present?

      # faculty of the course
      current_user.faculty&.cohorts&.exists?(id: student.cohort_id)
    end

    def submission
      @submission ||= TimelineEvent.find_by(id: @params[:submission_id])
    end

    def course
      @course ||= submission&.course
    end
  end
end
